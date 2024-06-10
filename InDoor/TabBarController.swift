//
//  TabBarController.swift
//  InDoor
//
//  Created by Sachko_AP on 10.06.2024.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupApperance()

    }
    
    private func setupApperance(){
        tabBar.tintColor = .gray
        tabBar.barTintColor = .gray
    }
    
    private func setupViewControllers() {
        
        let vc = SearchVC()
        let nc1 = UINavigationController(rootViewController: vc)
        vc.view.backgroundColor = .systemBackground
        
        let vc2 = NavigationVC()
        let nc2 = UINavigationController(rootViewController: vc2)
        
        let vc3 = BuildRouteVC()
        let nc3 = UINavigationController(rootViewController: vc3)
        vc3.view.backgroundColor = .systemBackground
        
        let vc4 = QRcodeVC()
        let nc4 = UINavigationController(rootViewController: vc4)
        vc4.view.backgroundColor = .systemBackground

        tabBar.standardAppearance = UITabBarAppearance()

        setViewControllers(
            [nc1, nc2, nc3, nc4],
            animated: false)
        
        selectedIndex = 1
    }
    
}
