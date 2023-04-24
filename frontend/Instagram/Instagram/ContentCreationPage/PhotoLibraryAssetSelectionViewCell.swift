//
//  PhotoLibraryAssetSelectionViewCell.swift
//  PhotoTestingApp
//
//  Created by brock davis on 10/12/22.
//

import UIKit

class PhotoLibraryAssetSelectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    var currentAssetIdentifier: String = ""
    
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }
 
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        self.backgroundView = backgroundView
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}
