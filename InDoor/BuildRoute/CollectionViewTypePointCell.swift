//
//  CollectionViewTypePointCell.swift
//  InDoor
//
//  Created by Sachko_AP on 16.06.2024.
//

import Foundation
import UIKit

class CollectionViewTypePointCell: UICollectionViewCell {
    static let reuseId = "CollectionViewTypePointCell"
        
    let pointLable: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        text.textColor = .init(red: 25, green: 102, blue: 255)
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 1
        text.textAlignment = .center
        return text
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(pointLable)
        
        layer.cornerRadius = 5

        clipsToBounds = false
        layer.masksToBounds = false
        
        backgroundColor = .init(red: 25, green: 102, blue: 255).withAlphaComponent(0.12)

        pointLable.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pointLable.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pointLable.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pointLable.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

