//
//  searchVC.swift
//  InDoorVs2
//
//  Created by Sap on 16.10.2023.
//

import UIKit

class SearchVC: UIViewController {
    
    private var data: [String] = []
    var filteredData = [String]()
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xD9D9D9)
        data = fillingDataTableViewCell(letter: "Г")

        tableViewSearcAudit.dataSource = self
        tableViewSearcAudit.delegate = self
        tableViewSearcAudit.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableViewSearcAudit)
        
        searchBarSearchAudit.delegate = self
        searchBarSearchAudit.placeholder = "Введите запрос"
        view.addSubview(searchBarSearchAudit)
        searchBarSearchAudit.addSubview(lineBottomSearchBar)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.isHidden = true


        
        setupConstraints()
        setupTabbarItem()
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
    
    private func setupTabbarItem() {
        tabBarItem = UITabBarItem(
            title: "",
            image: ImageConstants.Image.SearchVC.imageTabBarGlavnaia,
            tag: 1
        )
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
            cell.textLabel?.text = data[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NavigationVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = data.filter({ $0.lowercased().contains(searchText.lowercased()) })
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
