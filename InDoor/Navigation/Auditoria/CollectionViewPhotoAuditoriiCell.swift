//
//  CollectionViewPhotoAuditoriiCell.swift
//  InDoorVs2
//
//  Created by Sap on 20.05.2024.
//

import Foundation
import UIKit

class CollectionViewPhotoAuditoriiCell: UICollectionViewCell {
    static let reuseId = "CollectionViewPhotoAuditoriiCell"
    
    static var gifZagruzkaVstoennaia: UIActivityIndicatorView = {
            let view = UIActivityIndicatorView()
            view.color = .black
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
    let mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 19
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(mainImageView)
        addSubview(CollectionViewPhotoAuditoriiCell.gifZagruzkaVstoennaia)

        
        layer.cornerRadius = 19
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 4.0

        clipsToBounds = false
        layer.masksToBounds = false

        mainImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

//        mainImageView.heightAnchor.constraint(equalToConstant: 172).isActive = true
//        mainImageView.widthAnchor.constraint(equalToConstant: 165).isActive = true
        
        CollectionViewPhotoAuditoriiCell.gifZagruzkaVstoennaia.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        CollectionViewPhotoAuditoriiCell.gifZagruzkaVstoennaia.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

