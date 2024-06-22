//
//  ChatVc.swift
//  InDoorVs2
//
//  Created by Sap on 18.10.2023.
//
import UIKit

class BuildRouteVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var data: [String: Int] = [:]
    let setDataAuditoriiNotification = Notification.Name("SetDataAuditoriiNotification")
    let buildRouteNotification = Notification.Name("BuildRouteToMarker")
    let standartTypePoint = ["Туалет", "Аудитория", "Лекционный зал", "Холл"]
    var filteredData = [String]()
    var collectionTopConstraint: NSLayoutConstraint?

    private let marshrutLable: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        text.textColor = .black
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
        text.text = "Маршрут"
        return text
    }()
    private let closeButtonAuditoria: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = ImageConstants.Image.Auditoria.closeButtonAuditoria
        button.setImage(image, for: .normal)
        return button
    }()
    private let imageAPoint: UIImageView = {
        let bottomBorder = UIImageView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.layer.cornerRadius = 19
        bottomBorder.image = ImageConstants.Image.Marshrut.imageA
        return bottomBorder
    }()
    private let imageBPoint: UIImageView = {
        let bottomBorder = UIImageView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.layer.cornerRadius = 19
        bottomBorder.image = ImageConstants.Image.Marshrut.imageB
        return bottomBorder
    }()
        
    private let otkudaTextView: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.layer.cornerRadius = 5
        search.placeholder = "Откуда"
        search.searchTextField.font = UIFont.systemFont(ofSize: 16) // Увеличение размера текста
        search.searchTextField.textColor = UIColor.gray.withAlphaComponent(0.3) // Прозрачный цвет текста
        search.searchTextField.textAlignment = .left // Центральное выравнивание текста по вертикали
        search.layer.borderWidth = 1.0 // Толщина границы
        search.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor // Прозрачный цвет границ
        search.searchTextField.backgroundColor = .clear
        search.backgroundColor = .clear
        search.isTranslucent = true
        search.barTintColor = .none
        search.searchTextField.textColor = .black
        search.searchBarStyle = .default
        search.layer.zPosition = 0
        return search
    }()

    private let kudaTextView: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.layer.cornerRadius = 5
        search.placeholder = "Куда"
        search.searchTextField.font = UIFont.systemFont(ofSize: 16) // Увеличение размера текста
        search.searchTextField.textColor = UIColor.gray.withAlphaComponent(0.3) // Прозрачный цвет текста
        search.searchTextField.textAlignment = .left // Центральное выравнивание текста по вертикали
        search.layer.borderWidth = 1.0 // Толщина границы
        search.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor // Прозрачный цвет границ
        search.searchTextField.backgroundColor = .clear
        search.backgroundColor = .clear
        search.isTranslucent = true
        search.barTintColor = .none
        search.searchTextField.textColor = .black
        search.searchBarStyle = .default
        search.layer.zPosition = 0
        return search
    }()

    private let swapPoint: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = ImageConstants.Image.Marshrut.swapPoint
        button.setImage(image, for: .normal)
        return button
    }()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let tableViewTopResultOtkuda: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.zPosition = 1
        return tableView
    }()

    private let tableViewTopResultKuda: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.zPosition = 1
        return tableView
    }()
    private let buildRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .systemBlue
        button.setTitle("Построить маршрут", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()


    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tableViewTopResultOtkuda.isHidden = true
        tableViewTopResultKuda.isHidden = true
        buildRouteButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xD9D9D9)
        otkudaTextView.delegate = self
        kudaTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded), name: setDataAuditoriiNotification, object: nil)

        
        // Создание UICollectionView
        collectionView.register(CollectionViewTypePointCell.self, forCellWithReuseIdentifier: CollectionViewTypePointCell.reuseId)
        collectionView.dataSource = self
        
        let flowLayoutService = UICollectionViewFlowLayout()
        flowLayoutService.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayoutService
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        // Создание tableViewTopResult
        tableViewTopResultOtkuda.dataSource = self
        tableViewTopResultOtkuda.delegate = self
        tableViewTopResultOtkuda.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableViewTopResultKuda.dataSource = self
        tableViewTopResultKuda.delegate = self
        tableViewTopResultKuda.register(UITableViewCell.self, forCellReuseIdentifier: "cell")


        view.addSubview(closeButtonAuditoria)
        view.addSubview(marshrutLable)
        view.addSubview(imageAPoint)
        view.addSubview(imageBPoint)
        view.addSubview(otkudaTextView)
        view.addSubview(kudaTextView)
        view.addSubview(swapPoint)
        
        view.addSubview(buildRouteButton)
        view.addSubview(collectionView)

        view.addSubview(tableViewTopResultOtkuda)
        view.addSubview(tableViewTopResultKuda)

        setConstrains()
        setupTabbarItem()
        collectionTopConstraint = self.collectionView.topAnchor.constraint(equalTo: kudaTextView.bottomAnchor, constant: 20)
        collectionTopConstraint?.isActive = true
    }
    
    //MARK: DataLoaded
    @objc func dataLoaded(_ notification: Notification) {
        if let data = notification.object as? [[String: Any]] {
            for dict in data {
                if let name = dict["name"] as? String, name != "", let id = dict["id"] as? Int {
                    self.data[name] = id
                }
            }
        }
    }

    deinit {
        // Отмена регистрации обработчика уведомления при уничтожении объекта
        NotificationCenter.default.removeObserver(self, name: buildRouteNotification, object: nil)
    }




    private func setConstrains(){
        
        NSLayoutConstraint.activate([
            marshrutLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            marshrutLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            closeButtonAuditoria.centerYAnchor.constraint(equalTo: marshrutLable.centerYAnchor),
            closeButtonAuditoria.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButtonAuditoria.heightAnchor.constraint(equalToConstant: 25),
            closeButtonAuditoria.widthAnchor.constraint(equalToConstant: 25),
            
            imageAPoint.topAnchor.constraint(equalTo: marshrutLable.bottomAnchor, constant: 40),
            imageAPoint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageAPoint.heightAnchor.constraint(equalToConstant: 30),
            imageAPoint.widthAnchor.constraint(equalToConstant: 30),
            
            imageBPoint.centerXAnchor.constraint(equalTo: imageAPoint.centerXAnchor),
            imageBPoint.topAnchor.constraint(equalTo: imageAPoint.bottomAnchor, constant: 20),
            imageBPoint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageBPoint.heightAnchor.constraint(equalToConstant: 30),
            imageBPoint.widthAnchor.constraint(equalToConstant: 30),
            
            swapPoint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            swapPoint.centerYAnchor.constraint(equalTo: imageAPoint.centerYAnchor, constant: 30),
            swapPoint.heightAnchor.constraint(equalToConstant: 30),
            swapPoint.widthAnchor.constraint(equalToConstant: 30),
            
            otkudaTextView.centerYAnchor.constraint(equalTo: imageAPoint.centerYAnchor),
            otkudaTextView.leadingAnchor.constraint(equalTo: imageAPoint.trailingAnchor, constant: 10),
            otkudaTextView.trailingAnchor.constraint(equalTo: swapPoint.leadingAnchor, constant: -10),
//            otkudaTextView.widthAnchor.constraint(equalToConstant: 150),
            otkudaTextView.heightAnchor.constraint(equalToConstant: 40),
            
            tableViewTopResultOtkuda.topAnchor.constraint(equalTo: otkudaTextView.bottomAnchor,constant: 10),
            tableViewTopResultOtkuda.leadingAnchor.constraint(equalTo: otkudaTextView.leadingAnchor),
            tableViewTopResultOtkuda.trailingAnchor.constraint(equalTo: otkudaTextView.trailingAnchor),
            tableViewTopResultOtkuda.heightAnchor.constraint(equalToConstant: 40),
            
            kudaTextView.centerYAnchor.constraint(equalTo: imageBPoint.centerYAnchor),
            kudaTextView.leadingAnchor.constraint(equalTo: imageBPoint.trailingAnchor, constant: 10),
            kudaTextView.trailingAnchor.constraint(equalTo: swapPoint.leadingAnchor, constant: -10),
//            kudaTextView.widthAnchor.constraint(equalToConstant: 150),
            kudaTextView.heightAnchor.constraint(equalToConstant: 40),
            
            tableViewTopResultKuda.topAnchor.constraint(equalTo: kudaTextView.bottomAnchor,constant: 10),
            tableViewTopResultKuda.leadingAnchor.constraint(equalTo: kudaTextView.leadingAnchor),
            tableViewTopResultKuda.trailingAnchor.constraint(equalTo: kudaTextView.trailingAnchor),
            tableViewTopResultKuda.heightAnchor.constraint(equalToConstant: 40),
            
            buildRouteButton.topAnchor.constraint(equalTo: kudaTextView.bottomAnchor, constant: 10),
            buildRouteButton.widthAnchor.constraint(equalToConstant: 180),
            buildRouteButton.heightAnchor.constraint(equalToConstant: 40),
            buildRouteButton.centerXAnchor.constraint(equalTo: tableViewTopResultKuda.centerXAnchor),

            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 30),
            
        ])
    }
    
    private func setupTabbarItem() {
        tabBarItem = UITabBarItem(
            title: "",
            image: ImageConstants.Image.Marshrut.imageTabBarMarshrut,
            tag: 3
        )
    }
}


extension BuildRouteVC: UITextViewDelegate {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return standartTypePoint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewTypePointCell.reuseId, for: indexPath) as! CollectionViewTypePointCell
        cell.pointLable.text = standartTypePoint[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = calculateTextWidth(text: standartTypePoint[indexPath.row], font: UIFont.systemFont(ofSize: 18))
        return CGSize(width: cellWidth+15, height: 30)
    }
        
    func calculateTextWidth(text: String, font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        return size.width
    }

}

extension BuildRouteVC:  UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if otkudaTextView.text != "" {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemGray
        cell.textLabel?.textColor = UIColor.systemBackground.inverted
        cell.layer.cornerRadius = 10

        if otkudaTextView.text != "" {
            cell.textLabel?.text = filteredData[indexPath.row]
        } else {
            let key = Array(self.data.keys)
            cell.textLabel?.text = key[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewTopResultOtkuda {
            otkudaTextView.text = filteredData[indexPath.row]
            tableViewTopResultOtkuda.isHidden = true
        } else if tableView == tableViewTopResultKuda {
            kudaTextView.text = filteredData[indexPath.row]
            tableViewTopResultKuda.isHidden = true
        }
        
        let key = Array(self.data.keys)

        if let searchTextOtkuda = otkudaTextView.text, key.contains(searchTextOtkuda),
           let searchTextKuda = kudaTextView.text, key.contains(searchTextKuda) {
            buildRouteButton.isHidden = false
            collectionTopConstraint?.isActive = false
            collectionTopConstraint = self.collectionView.topAnchor.constraint(equalTo: buildRouteButton.bottomAnchor, constant: 10)
            collectionTopConstraint?.isActive = true
            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            print(kudaTextView.text ?? "No text")
        }


    }

}

extension BuildRouteVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let key = Array(self.data.keys)
        if searchBar == otkudaTextView {
            filteredData = key.filter({ $0.lowercased().contains(searchText.lowercased()) })
            tableViewTopResultOtkuda.reloadData()
        } else if searchBar == kudaTextView {
            filteredData = key.filter({ $0.lowercased().contains(searchText.lowercased()) })
            tableViewTopResultKuda.reloadData()
        }

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
       }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar == otkudaTextView {
            tableViewTopResultOtkuda.isHidden = false
        } else if searchBar == kudaTextView{
            tableViewTopResultKuda.isHidden = false
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar == otkudaTextView, searchBar.text?.isEmpty == false {
            tableViewTopResultOtkuda.isHidden = true
        } else if searchBar == kudaTextView, searchBar.text?.isEmpty == false {
            tableViewTopResultKuda.isHidden = true
        }
    }

}
