//
//  AlbumHeaderView.swift
//  PhotoTestingApp
//
//  Created by brock davis on 10/11/22.
//

import UIKit

class AlbumSectionHeaderView: UICollectionReusableView {
    
    private let label = UILabel()
    
    var sectionName: String? {
        didSet {
            if let sectionName = self.sectionName {
                let attributedSectionName = NSAttributedString(string: sectionName, attributes: [
                    .foregroundColor: UIColor.lightGray,
                    .font: UIFont.systemFont(ofSize: UIScreen.main.bounds.width / 24, weight: .semibold)
                ])
                self.label.attributedText = attributedSectionName
            }
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "ContentCreationPage/AlbumSelectionCellBackgroundColor")!
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.label)
        NSLayoutConstraint.activate([
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UIScreen.main.bounds.width * 0.028),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
