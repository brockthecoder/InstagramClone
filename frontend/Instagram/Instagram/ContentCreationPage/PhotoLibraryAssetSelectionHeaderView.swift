//
//  PhotoLibraryAssetSelectionHeaderView.swift
//  PhotoTestingApp
//
//  Created by brock davis on 10/12/22.
//

import UIKit

class PhotoLibraryAssetSelectionHeaderView: UICollectionReusableView {
    
    let button = UIButton()
    var selectedAlbum: String? {
        didSet {
            if let selectedAlbum = self.selectedAlbum {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                let attributedAlbumTitle = NSAttributedString(string: selectedAlbum, attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: UIScreen.main.bounds.width / 24, weight: .semibold)
                ])
                button.setAttributedTitle(attributedAlbumTitle, for: .normal)
            }
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .red
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.button)
        let viewWidth = UIScreen.main.bounds.width
        NSLayoutConstraint.activate([
            self.button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: viewWidth * 0.034),
            self.button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -viewWidth * 0.06)
        ])
    }
}
