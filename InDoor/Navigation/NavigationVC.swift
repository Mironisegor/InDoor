//
//  ViewController.swift
//  InDoorVs2
//
//  Created by Sap on 05.10.2023.
//
import UIKit
import Zip
import WebKit
import Swifter
import CoreGraphics


class NavigationVC: UIViewController {
    
    var webView: WKWebView!
    var tileMapsPath: URL!
    var server: HttpServer?
    var mapJSON: [[String: Any]] = []
    let buildRouteNotification = Notification.Name("BuildRouteToMarker")
    let setDataAuditoriiNotification = Notification.Name("SetDataAuditoriiNotification")


    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded), name: buildRouteNotification, object: nil)

        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        tileMapsPath = documentsPath.appendingPathComponent("InDoor")

        if fileManager.fileExists(atPath: tileMapsPath.path) {
            setUpMap()
            print("Данные карты существуют")
        } else {
            downloadTileMapAndSetUp()
            print("Данные карты отсутствуют")
        }
        setupTabbarItem()
    }
    
    //MARK: DataLoaded
    @objc func dataLoaded(_ notification: Notification) {
        if let data = notification.object as? Int {
            if let webView = webView {
                let jsFunctionCall = "buildRouteWithSwift(\(data));"
                webView.evaluateJavaScript(jsFunctionCall) { (result, error) in
                    if let error = error {
                        print("Error evaluating JavaScript: \(error)")
                    }
                }
            }
        }
    }

    deinit {
        // Отмена регистрации обработчика уведомления при уничтожении объекта
        NotificationCenter.default.removeObserver(self, name: buildRouteNotification, object: nil)
    }

}

// MARK: Read JSON
extension NavigationVC {
    
    struct Coordinates: Codable {
        let x: Int
        let y: Int
        let name: String
        let id: Int
        let connected: [Int]
        let photoUrls: [String]
        let description: String
    }
    
    func readLocalFile(forName name: String) -> [Coordinates] {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                guard let dictionary = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
                    throw NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка при разборе JSON"])
                }
                let dataFromResponce = dictionary["dots"] as! [[String: Any]]
                var returnArray: [Coordinates] = []

                for data in dataFromResponce{
                    let copyData = Coordinates(x: data["x"] as? Int ?? 0, y: data["y"] as? Int ?? 0, name: data["name"] as? String ?? "", id: data["id"] as? Int ?? 0, connected: data["connected"] as? [Int] ?? [0], photoUrls: data["photoUrls"] as? [String] ?? [""], description: data["description"] as? String ?? "")
                    returnArray.append(copyData)
                }
                return returnArray
            }
        } catch {
            print(error)
        }
        return [Coordinates]()
    }

}

//MARK: Open Map With Internet
extension NavigationVC {
    
    func listFiles(inDirectory directoryPath: String) -> [String]? {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) && isDirectory.boolValue else {
            // Если директория не существует или не является директорией, возвращаем nil
            return nil
        }

        do {
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
            return files
        } catch {
            print("Error: \(error)")
            // Если произошла ошибка при получении списка файлов, возвращаем nil
            return nil
        }
    }

    
    private func downloadTileMapAndSetUp() {
        let fileUrl = "http://141.8.198.123:3000/download-folder"

        createDirectoryIfNeeded(at: tileMapsPath)

        downloadFile(from: fileUrl) { tempLocalURL, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Ошибка загрузки файла: \(error.localizedDescription)")
                }
                return
            }
            
            guard let tempLocalURL = tempLocalURL else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Не удалось получить временный URL файла.")
                }
                return
            }
//            print("tempLocalURL: \(tempLocalURL)")
            // Переименование файла в .zip
            let zipURL = tempLocalURL.deletingPathExtension().appendingPathExtension("zip")
            do {
                try FileManager.default.moveItem(at: tempLocalURL, to: zipURL)
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Ошибка переименования файла: \(error.localizedDescription)")
                }
                return
            }

            // Распаковка файла
            self.unzipFile(at: zipURL, to: self.tileMapsPath) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Ошибка расархивации: \(error.localizedDescription)")
                    }
                } else {
//                    print("Файл успешно расархивирован в \(String(describing: self.tileMapsPath))")
                    // Проверяем содержимое распакованной папки
                    self.checkUnzippedContent(at: self.tileMapsPath) { success in
                        if success {
                            DispatchQueue.main.async { [weak self] in
                                self?.setUpMap()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showErrorAlert(message: "Распакованный контент не соответствует ожидаемому.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func setUpMap() {
        //webView
        let contentController = WKUserContentController()
        contentController.add(self, name: "logger")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // Инициализация локального веб-сервера
        server = HttpServer()
        
        guard let tileMapsDirectory = tileMapsPath?.appendingPathComponent("TileMap") else { return }
                
        let fileManager = FileManager.default

        // Получить список всех папок в TileMap
        let directoryContents = try! fileManager.contentsOfDirectory(atPath: tileMapsDirectory.path)

        // Переименовать каждую папку
        for z in directoryContents {
            if (Int(z) == nil) {
               continue
            }
            let oldPathZ = tileMapsDirectory.path + "/" + z
            var newPathZ = oldPathZ
            var newZ = z

            // Проверяем, имеет ли папка уже нужные имена для файлов
            if ["10", "11", "12", "13", "14"].contains(z) {
                continue
            }

            // Переименование папок "z", если они имеют имена "0", "1", "2", "3", "4"
            if ["0", "1", "2", "3", "4"].contains(z) {
                let newFolderNameZ = String(Int(z)! + 10)
                newPathZ = tileMapsDirectory.path + "/" + newFolderNameZ
                // Изменяем значение z
                if let intValue = Int(newZ) {
                    newZ = String(intValue + 10)
                }

                do {
                    try fileManager.moveItem(atPath: oldPathZ, toPath: newPathZ)
                } catch {
                    print("Error renaming folder 'z': \(error)")
                    continue
                }
            }

            guard (Int(newZ) != nil) else { continue }
            let directoryContentX = try! fileManager.contentsOfDirectory(atPath: newPathZ)
            var newZoomLevel: Int
            switch newZ {
              case "10":
                newZoomLevel = 1
              case "11":
                newZoomLevel = 2
              case "12":
                newZoomLevel = 4
              case "13":
                newZoomLevel = 8
              case "14":
                newZoomLevel = 16
              default:
                // Обработка неизвестных значений зума
                print("Неизвестный зум: \(newZ)")
                newZoomLevel = Int(newZ)!
            }

            for x in directoryContentX {
                guard let xLevel = Int(x) else { continue }

                let newFolderNameX = String(xLevel + 512 * newZoomLevel)//+10

                let oldPathX = newPathZ + "/" + x
                let newPathX = newPathZ + "/" + newFolderNameX
                do {
                    // Перемещаем папку с исходным именем
                    try fileManager.moveItem(atPath: oldPathX, toPath: newPathX)

                    // Получаем содержимое новой папки
                    let directoryContentY = try fileManager.contentsOfDirectory(atPath: newPathX)

                    // Перебираем содержимое папки
                    for y in directoryContentY {
                        // Проверяем, что файл - изображение с расширением .jpg
                        guard y.lowercased().hasSuffix(".jpg") else {
                            continue
                        }

                        // Формируем путь к изображению
                        let oldPathY = newPathX + "/" + y

                        // Получаем имя файла без расширения
                        let fileNameWithoutExtension = URL(fileURLWithPath: y).deletingPathExtension().lastPathComponent

                        // Создаем новое имя для изображения, добавляя к имени числовой суффикс
                        let newFileNameY = "\(512 * newZoomLevel+Int(fileNameWithoutExtension)!).jpg"

                        // Формируем новый путь для изображения
                        let newPathY = newPathX + "/" + newFileNameY

                        do {
                            // Переименовываем изображение, перемещая его
                            try fileManager.moveItem(atPath: oldPathY, toPath: newPathY)
                        } catch {
                            print("Error renaming image: \(error)")
                        }
                    }
                } catch {
                    print("Error renaming folder: \(error)")
                }

            }
        }
                
        do {
            server?["/*/*/*"] = { request in
                // Извлекаем полный путь из запроса, отбрасывая первый "/"
                let path = request.path.dropFirst()
                let fullPath = "\(tileMapsDirectory)\(path)"

                guard FileManager.default.fileExists(atPath: fullPath) else {
                    // Если запрашиваемый файл не существует, возвращаем blank.jpg
                    let blankImagePath = tileMapsDirectory.appendingPathComponent("\(path)").path
                    guard let blankData = try? Data(contentsOf: URL(fileURLWithPath: blankImagePath)) else {
                        return .notFound
                    }
                    return .ok(.data(blankData, contentType: "image/jpeg"))
                }
                
                do {
                    let fileData = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                    let mimeType = fullPath.mimeType()
                    return .ok(.data(fileData, contentType: mimeType))
                } catch {
                    print("Error reading the file: \(error)")
                    return .internalServerError
                }
            }

            try server?.start(3000, forceIPv4: true)
        
            let localURL = "http://localhost:3000"
            if let url = Bundle.main.url(forResource: "OpenStreet", withExtension: "html") {
                let query = "?localTilePath=\(localURL)"
                let fullURL = URL(string: url.absoluteString + query)!
                let request = URLRequest(url: fullURL)
                webView.load(request)
            }

        } catch {
            print("Не удалось запустить сервер: \(error)")
        }
    }
    
    func callAddMarkersFromSwift() {
        var keyValuePairs1: [[String: Any]] = []
        let newsNew = readLocalFile(forName: "map")
        for i in newsNew {
            var keyValuePairs: [String: Any] = [:]
            keyValuePairs["x"] = i.x
            keyValuePairs["y"] = i.y
            keyValuePairs["name"] = i.name
            keyValuePairs["id"] = i.id
            keyValuePairs["connected"] = i.connected
            keyValuePairs["photoUrls"] = i.photoUrls
            keyValuePairs["description"] = i.description
            keyValuePairs1.append(keyValuePairs)
        }
        mapJSON = keyValuePairs1
        NotificationCenter.default.post(name: self.setDataAuditoriiNotification, object: mapJSON)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: keyValuePairs1, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let jsCommand = "addMarkers(\(jsonString));"
                webView.evaluateJavaScript(jsCommand) { (result, error) in
                    if let error = error {
                        print("Error evaluating JavaScript: \(error)")
                    }
                }
            }
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }

    }

    
    private func createDirectoryIfNeeded(at path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.path) {
            do {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
    }
    
    private func unzipFile(at sourceURL: URL, to destinationURL: URL, completion: @escaping (Error?) -> Void) {
        do {
//            print("Проверяем, существует ли файл: \(sourceURL.path)")
            guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                print("Файл не существует по пути: \(sourceURL.path)")
                throw NSError(domain: "File does not exist", code: 0, userInfo: nil)
            }
            
//            print("Проверяем, является ли файл zip-архивом.")
            guard sourceURL.pathExtension == "zip" else {
                print("Файл не является zip-архивом: \(sourceURL.path)")
                throw NSError(domain: "File is not a zip archive", code: 0, userInfo: nil)
            }
            
//            print("Пытаемся распаковать файл.")
            try Zip.unzipFile(sourceURL, destination: destinationURL, overwrite: true, password: nil)
//            print("Файл успешно распакован.")
            completion(nil)
        } catch {
            print("Ошибка при распаковке файла: \(error)")
            completion(error)
        }
    }

    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func downloadFile(from urlString: String, completion: @escaping (URL?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let localURL = localURL else {
                completion(nil, NSError(domain: "FileDownloadError", code: 0, userInfo: nil))
                return
            }
            completion(localURL, nil)
        }
        task.resume()
    }
    
    private func checkUnzippedContent(at path: URL, completion: (Bool) -> Void) {
        let fileManager = FileManager.default
        let tilesPath = path.appendingPathComponent("TileMap")
        
        // Проверяем наличие папки ПлиткиКарт
        guard fileManager.fileExists(atPath: tilesPath.path) else {
            print("Папка ПлиткиКарт не найдена")
            completion(false)
            return
        }
        
        // Проверяем содержимое папки ПлиткиКарт
        do {
            let tilesContents = try fileManager.contentsOfDirectory(atPath: tilesPath.path)
//            print("Содержимое папки ПлиткиКарт: \(tilesContents)")
            completion(!tilesContents.isEmpty)
        } catch {
            print("Ошибка при чтении содержимого папки ПлиткиКарт: \(error)")
            completion(false)
        }
    }

}


//MARK: SetUp TabBar Item
extension NavigationVC {
    private func setupTabbarItem() {
        tabBarItem = UITabBarItem(
            title: "",
            image: ImageConstants.Image.Navigation.imageTabBarNavigation,
            tag: 2
        )
    }
}

extension NavigationVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if #available(iOS 16.4, *) {
          webView.isInspectable = true
        }
        callAddMarkersFromSwift()
    }
}


extension NavigationVC: WKScriptMessageHandler {
    // Функция для поиска элемента по id
    func findElementById(id: Int, in array: [[String: Any]]) -> [String: Any]? {
        for element in array {
            if let elementId = element["id"] as? Int, elementId == id {
                return element
            }
        }
        return nil
    }


    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == "logger" {
//            print(message.body)
            let components = (message.body as AnyObject).components(separatedBy: " - ")

            if components.count == 2 {
                let id = components[1]
                if let IntId = Int(id) {
                    
                } else {
                    return
                }
                // Использование функции для поиска элемента по id
                if let foundElement = findElementById(id: Int(id)!, in: mapJSON) {
                    if let photoUrls = foundElement["photoUrls"] as? [String], let name = foundElement["name"] as? String, let description = foundElement["description"] as? String {
                        let vc = AuditoriaVC(name: name, photoUrls: photoUrls, descriptions: description, idAuditorii: Int(id)!)
                        vc.hidesBottomBarWhenPushed = true
                        navigationController?.pushViewController(vc, animated: false)
                    } else {
                        print("Не удалось найти photoUrls или имя или description для данного id")
                    }
                } else {
                    print("Элемент с указанным id не найден")
                }

            } else {
                print("Некорректный формат строки")
            }

        }

    }
}

extension String {
    func mimeType() -> String {
        let pathExtension = self.lowercased()
        switch pathExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "html":
            return "text/html"
        // Добавьте другие расширения и MIME-типы по мере необходимости
        default:
            return "application/octet-stream"
        }
    }
}

//расширение библиотеки с цветом для облегчения его указания
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
