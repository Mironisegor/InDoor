//
//  TableViewCellListMarkers.swift
//  InDoor
//
//  Created by Sachko_AP on 27.06.2024.
//

import Foundation
import UIKit

class TableViewCellListMarkers: UITableViewCell {
    static let reuseId = "TableViewCellListMarkers"
    
    let nameLable: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        text.textColor = .init(red: 25, green: 102, blue: 255)
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 1
        text.textAlignment = .center
        
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: -0.4, range: NSRange(location: 0, length: attributedString.length))
        text.attributedText = attributedString
        
        return text
    }()
        
    let typeLable: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        text.textColor = .black
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 1
        text.textAlignment = .center
        return text
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLable)
        addSubview(typeLable)
        
        layer.cornerRadius = 5

        clipsToBounds = false
        layer.masksToBounds = false
        
//        backgroundColor = .blue.withAlphaComponent(0.1)

//        nameLable.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20).isActive = true
        nameLable.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
//        nameLable.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        typeLable.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor).isActive = true
        typeLable.topAnchor.constraint(equalTo: nameLable.bottomAnchor, constant: 1).isActive = true
//        typeLable.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        typeLable.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

