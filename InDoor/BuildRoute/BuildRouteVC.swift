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
    
    private let otkudaTextView: UITextView = {
        let textview = UITextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.layer.cornerRadius = 5
        textview.text = "Откуда"
        textview.layer.borderWidth = 1.0 // Толщина границы
        textview.layer.borderColor = UIColor.gray.cgColor // Цвет границ
        return textview
    }()
    private let kudaTextView: UITextView = {
        let textview = UITextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.layer.cornerRadius = 5
        textview.text = "Куда"
        textview.layer.borderWidth = 1.0 // Толщина границы
        textview.layer.borderColor = UIColor.gray.cgColor // Цвет границ
        return textview
    }()


    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(rgb: 0xD9D9D9)

        view.addSubview(closeButtonAuditoria)
        view.addSubview(marshrutLable)
        view.addSubview(imageAPoint)
        view.addSubview(imageBPoint)
        view.addSubview(otkudaTextView)
        view.addSubview(kudaTextView)
        setConstrains()
        setupTabbarItem()
    }


    private func setConstrains(){
        
        NSLayoutConstraint.activate([
            marshrutLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            marshrutLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            closeButtonAuditoria.centerYAnchor.constraint(equalTo: marshrutLable.centerYAnchor),
            closeButtonAuditoria.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButtonAuditoria.heightAnchor.constraint(equalToConstant: 25),
            closeButtonAuditoria.widthAnchor.constraint(equalToConstant: 25),
            
            imageAPoint.topAnchor.constraint(equalTo: marshrutLable.bottomAnchor, constant: 50),
            imageAPoint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageAPoint.heightAnchor.constraint(equalToConstant: 30),
            imageAPoint.widthAnchor.constraint(equalToConstant: 30),
            
            imageBPoint.centerXAnchor.constraint(equalTo: imageAPoint.centerXAnchor),
            imageBPoint.topAnchor.constraint(equalTo: imageAPoint.bottomAnchor, constant: 10),
            imageBPoint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageBPoint.heightAnchor.constraint(equalToConstant: 30),
            imageBPoint.widthAnchor.constraint(equalToConstant: 30),
            
            otkudaTextView.centerYAnchor.constraint(equalTo: imageAPoint.centerYAnchor),
            otkudaTextView.leadingAnchor.constraint(equalTo: imageAPoint.trailingAnchor, constant: 10),
            otkudaTextView.widthAnchor.constraint(equalToConstant: 150),
            otkudaTextView.heightAnchor.constraint(equalToConstant: 40),

            kudaTextView.centerYAnchor.constraint(equalTo: imageBPoint.centerYAnchor),
            kudaTextView.leadingAnchor.constraint(equalTo: imageBPoint.trailingAnchor, constant: 10),
            kudaTextView.widthAnchor.constraint(equalToConstant: 150),
            kudaTextView.heightAnchor.constraint(equalToConstant: 40),


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
