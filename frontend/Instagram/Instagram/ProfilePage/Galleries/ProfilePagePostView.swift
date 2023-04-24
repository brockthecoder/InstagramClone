//
//  ProfilePagePostView.swift
//  InstagramClone
//
//  Created by brock davis on 1/22/23.
//

import UIKit

class ProfilePagePostView: UICollectionViewCell {
    
    private let thumbnailView = UIImageView()
    private let postTypeIconView = UIImageView()
    
    var post: ProfilePagePost? {
        didSet {
            guard let post else {
                self.thumbnailView.image = nil
                self.postTypeIconView.image = nil
                return
            }
            self.thumbnailView.image = post.thumbnail
            self.postTypeIconView.image = {
                if post.isPinned {
                    return Configurations.pinnedIcon
                } else if post.isReel {
                    return Configurations.reelIcon
                } else if post.isCarousel {
                    return Configurations.carouselIcon
                } else if post.hasShoppingLinks {
                    return Configurations.shoppingIcon
                } else {
                    return nil
                }
            }()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Thumbnail view
        self.contentView.addSubview(self.thumbnailView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ])
        }
        
        // Post type icon view
        self.thumbnailView.addSubview(self.postTypeIconView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: self.thumbnailView.trailingAnchor, constant: Configurations.iconCenterXOffset),
                $0.centerYAnchor.constraint(equalTo: self.thumbnailView.topAnchor, constant: Configurations.iconCenterYOffset)
            ])
        }
        
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let pinnedIconSize = CGSize.sqaure(size: screenWidth * 0.04410517387616624257)
    static let carouselIconSize = CGSize.sqaure(size: 16)
    static let shoppingIconSize = CGSize(width: screenWidth * 0.04071246819338422391, height: screenWidth * 0.04325699745547073791)
    static let reelIconSize =  CGSize.sqaure(size: 48.0 / 3.0)
    static let iconFillColor = UIColor(named: "ProfilePage/PostView/iconFillColor")!
    
    static let pinnedIcon = UIImage(named: "ProfilePage/PostView/pinnedIcon")!.resizedTo(size: pinnedIconSize).withTintColor(iconFillColor)
    static let carouselIcon = UIImage(named: "ProfilePage/PostView/carouselIcon")!.resizedTo(size: carouselIconSize).withTintColor(iconFillColor)
    static let shoppingIcon = UIImage(named: "ProfilePage/PostView/shoppingIcon")!.resizedTo(size: shoppingIconSize).withTintColor(iconFillColor)
    
    static let reelIcon = UIImage(named: "ProfilePage/PostView/reelIcon")!.resizedTo(size: reelIconSize).withTintColor(iconFillColor)
    
    static let iconCenterXOffset: CGFloat = -16
    static let iconCenterYOffset: CGFloat = 16
}
