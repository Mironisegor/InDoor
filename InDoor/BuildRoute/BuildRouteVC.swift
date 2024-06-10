//
//  ChatVc.swift
//  InDoorVs2
//
//  Created by Sap on 18.10.2023.
//
import UIKit

class BuildRouteVC: UIViewController {
    
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


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xD9D9D9)

        view.addSubview(closeButtonAuditoria)
        view.addSubview(marshrutLable)
        setConstrains()
        setupTabbarItem()
    }


    private func setConstrains(){
        
        NSLayoutConstraint.activate([
            marshrutLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            marshrutLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            closeButtonAuditoria.centerYAnchor.constraint(equalTo: marshrutLable.centerYAnchor),
            closeButtonAuditoria.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButtonAuditoria.heightAnchor.constraint(equalToConstant: 25),
            closeButtonAuditoria.widthAnchor.constraint(equalToConstant: 25),

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
