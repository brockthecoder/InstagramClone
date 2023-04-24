//
//  AssetCollectionTableViewCell.swift
//  PhotoTestingApp
//
//  Created by brock davis on 10/11/22.
//

import UIKit
import Photos

class AlbumCollectionViewCell: UICollectionViewCell {
    
    private let albumCover = UIImageView()
    private let albumTitleLabel = UILabel()
    private let albumAssetCountLabel = UILabel()
    
    private var viewWidthForLayout: CGFloat {
        (self.bounds.width != 0) ? self.bounds.width : UIScreen.main.bounds.width
    }
    
    private var viewHeightForLayout: CGFloat {
        self.viewWidthForLayout * 0.232
    }
    
    var albumCoverImage: UIImage? {
        didSet {
            if let albumCoverImage = self.albumCoverImage {
                self.albumCover.image = albumCoverImage
            }
        }
    }
    
    var albumTitle: String? {
        didSet {
            if let albumTitle = self.albumTitle {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                let attributedTitle = NSAttributedString(string: albumTitle, attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: self.viewWidthForLayout / 20, weight: .regular),
                    .paragraphStyle: paragraphStyle
                ])
                self.albumTitleLabel.attributedText = attributedTitle
            }
        }
    }
    
    var albumAssetCount: Int? {
        didSet {
            if let albumAssetCount = self.albumAssetCount {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                let attributedAssetCount = NSAttributedString(string: String(albumAssetCount),attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: self.viewWidthForLayout / 27, weight: .regular),
                    .paragraphStyle: paragraphStyle
                ])
                self.albumAssetCountLabel.attributedText = attributedAssetCount
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let backgroundView = UIView()
        let selectedBackgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "ContentCreationPage/AlbumSelectionCellBackgroundColor")!
        selectedBackgroundView.backgroundColor = UIColor(named: "ContentCreationPage/AlbumSelectionCellSelectedBackgroundColor")!
        self.backgroundView = backgroundView
        self.selectedBackgroundView = selectedBackgroundView
        
        self.albumCover.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.albumCover)
        NSLayoutConstraint.activate([
            self.albumCover.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: self.viewWidthForLayout * 0.028),
            self.albumCover.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.albumCover.widthAnchor.constraint(equalToConstant: self.viewWidthForLayout * 0.2),
            self.albumCover.heightAnchor.constraint(equalTo: self.albumCover.widthAnchor)
        ])
        
        self.albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.albumTitleLabel)
        NSLayoutConstraint.activate([
            self.albumTitleLabel.leadingAnchor.constraint(equalTo: self.albumCover.trailingAnchor, constant: self.viewWidthForLayout * 0.028),
            self.albumTitleLabel.topAnchor.constraint(equalTo: self.albumCover.topAnchor, constant: self.viewHeightForLayout * 0.165),
            self.albumTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
        
        self.albumAssetCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.albumAssetCountLabel)
        NSLayoutConstraint.activate([
            self.albumAssetCountLabel.topAnchor.constraint(equalTo: self.albumTitleLabel.bottomAnchor, constant: self.viewHeightForLayout * 0.075),
            self.albumAssetCountLabel.leadingAnchor.constraint(equalTo: self.albumTitleLabel.leadingAnchor),
            self.albumAssetCountLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30)
        ])
    }

}
