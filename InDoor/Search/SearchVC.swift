//
//  searchVC.swift
//  InDoorVs2
//
//  Created by Sap on 16.10.2023.
//

import UIKit

class SearchVC: UIViewController {
    
    private var data: [String: Int] = [:]
    var filteredData = [String]()
    let setDataAuditoriiNotification = Notification.Name("setDataAuditoriiNotification")
    let buildRouteNotification = Notification.Name("BuildRouteToMarker")

    private let tableViewSearcAudit: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let searchBarSearchAudit: UISearchBar = {
        let search = UISearchBar()
        search.backgroundColor = .clear
        search.isTranslucent = true
        search.barTintColor = .none
        search.searchTextField.textColor = .black
        search.translatesAutoresizingMaskIntoConstraints = false
        search.layer.borderWidth = 0
        search.searchBarStyle = .default
        return search
    }()
    private let lineBottomSearchBar: UIView = {
        let bottomBorder = UIView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = UIColor.blue
        return bottomBorder
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = .white
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xD9D9D9)
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded), name: setDataAuditoriiNotification, object: nil)

        tableViewSearcAudit.dataSource = self
        tableViewSearcAudit.delegate = self
        tableViewSearcAudit.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableViewSearcAudit)
        
        searchBarSearchAudit.delegate = self
        searchBarSearchAudit.placeholder = "Введите запрос"
        view.addSubview(searchBarSearchAudit)
        searchBarSearchAudit.addSubview(lineBottomSearchBar)
                
        setupConstraints()
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
        NotificationCenter.default.removeObserver(self, name: setDataAuditoriiNotification, object: nil)
    }

    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            searchBarSearchAudit.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarSearchAudit.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarSearchAudit.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarSearchAudit.heightAnchor.constraint(equalToConstant: 60),

            lineBottomSearchBar.bottomAnchor.constraint(equalTo: searchBarSearchAudit.bottomAnchor),
            lineBottomSearchBar.leftAnchor.constraint(equalTo: searchBarSearchAudit.leftAnchor),
            lineBottomSearchBar.rightAnchor.constraint(equalTo: searchBarSearchAudit.rightAnchor),
            lineBottomSearchBar.heightAnchor.constraint(equalToConstant: 2),

            tableViewSearcAudit.topAnchor.constraint(equalTo: searchBarSearchAudit.bottomAnchor),
            tableViewSearcAudit.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewSearcAudit.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewSearcAudit.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    func fillingDataTableViewCell(letter: String) -> [String]{
        var auditStr: String = ""
        var listAudit: [String] = []
        for floor in 301...345{
            auditStr = letter + "-" + "\(floor)"
            listAudit.append(auditStr)
        }
        return listAudit
    }
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarSearchAudit.text != "" {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBackground
        cell.textLabel?.textColor = UIColor.systemBackground.inverted

        if searchBarSearchAudit.text != "" {
            cell.textLabel?.text = filteredData[indexPath.row]
        } else {
            let key = Array(self.data.keys)
            cell.textLabel?.text = key[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let values = Array(self.data.values)
        let dataForBuildRoute = [1, values[indexPath.row]]
        NotificationCenter.default.post(name: self.buildRouteNotification, object: dataForBuildRoute)
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let key = Array(self.data.keys)
        filteredData = key.filter({ $0.lowercased().contains(searchText.lowercased()) })
        tableViewSearcAudit.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder() // Убираем клавиатуру при нажатии "Готово"
       }
}


extension UIColor {
    var inverted: UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Инвертирование цветовых компонентов
        return UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha)
    }
}
