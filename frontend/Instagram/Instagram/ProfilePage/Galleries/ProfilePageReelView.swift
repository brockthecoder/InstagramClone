//
//  ProfilePageReelView.swift
//  InstagramClone
//
//  Created by brock davis on 1/23/23.
//

import UIKit

class ProfilePageReelView: UICollectionViewCell {
    
    private let coverImageView = UIImageView()
    private let playsIconView = UIImageView()
    private let playCountLabel = UILabel()
    private let pinnedIconView = UIImageView()
    
    var reel: ProfilePageReel? {
        didSet {
            guard let reel else {
                self.coverImageView.image = nil
                self.pinnedIconView.isHidden = true
                self.playCountLabel.attributedText = NSAttributedString(string: "0", attributes: Configurations.playCountTextAttributes)
                return
            }
            self.coverImageView.image = reel.coverImage
            self.playCountLabel.attributedText = NSAttributedString(string: Configurations.formattedCountNumber(forCount: reel.playCount), attributes: Configurations.playCountTextAttributes)
            self.pinnedIconView.isHidden = !reel.isPinned
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.coverImageView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                $0.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
            ])
        }
        
        self.playsIconView.image = Configurations.playsIcon
        self.playsIconView.layer.shadowRadius = 0.35
        self.playsIconView.layer.shadowOffset = .zero
        self.playsIconView.layer.shadowOpacity = 0.25
        self.coverImageView.addSubview(self.playsIconView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: self.coverImageView.leadingAnchor, constant: Configurations.playsIconCenterXOffset),
                $0.centerYAnchor.constraint(equalTo: self.coverImageView.bottomAnchor, constant: Configurations.playsIconCenterYOffset)
            ])
        }
        
        self.coverImageView.addSubview(self.playCountLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerYAnchor.constraint(equalTo: self.playsIconView.centerYAnchor),
                $0.leadingAnchor.constraint(equalTo: self.playsIconView.trailingAnchor, constant: Configurations.playCountLeadingSpacing)
            ])
        }
        
        self.pinnedIconView.image = Configurations.pinnedIcon
        self.coverImageView.addSubview(self.pinnedIconView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerYAnchor.constraint(equalTo: self.coverImageView.topAnchor, constant: Configurations.pinnedIconCenterYOffset),
                $0.centerXAnchor.constraint(equalTo: self.coverImageView.trailingAnchor, constant: Configurations.pinnedIconCenterXOffset)
            ])
        }
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let playsIconSize = CGSize(width: screenWidth * 0.02374893977947413061, height: screenWidth * 0.02629346904156064461)
    static let playsIconCenterXOffset = screenWidth * 0.03647158608990670059
    static let playsIconCenterYOffset = -screenWidth * 0.03647158608990670059
    static let playsIcon = UIImage(named: "ProfilePage/ReelView/playsIcon")!.withTintColor(UIColor(named: "ProfilePage/ReelView/iconFillColor")!).resizedTo(size: playsIconSize)
    
    static let playCountLeadingSpacing = screenWidth * 0.01187446988973706531
    static let playCountTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/ReelView/playCountTextColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.03247, weight: .semibold),
        .shadow: {
           let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.25)
            shadow.shadowBlurRadius = 1
            return shadow
        }()
    ]
    
    static let pinnedIconSize = CGSize.sqaure(size: screenWidth * 0.03731976251060220525)
    static let pinnedIcon = UIImage(named: "ProfilePage/ReelView/pinnedIcon")!.withTintColor(UIColor(named: "ProfilePage/ReelView/iconFillColor")!).resizedTo(size: pinnedIconSize)
    static let pinnedIconCenterYOffset: CGFloat = 16
    static let pinnedIconCenterXOffset: CGFloat = -16
    
    static let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    
    static func formattedCountNumber(forCount count: Int) -> String {
            if count < 10000 {
                return numberFormatter.string(from: count as NSNumber)!
            } else if count < 100000 {
                let quotient = String(count / 1000)
                let remainder = String((count - (Int(quotient)! * 1000)) / 100)
                return remainder == "0" ? "\(quotient)K" : "\(quotient).\(remainder)K"
            } else if count < 1000000 {
                return "\(count / 1000)K"
            } else {
                let quotient = String(count / 1000000)
                let remainder = String((count - (Int(quotient)! * 1_000_000)) / 100000)
                return remainder == "0" ? "\(quotient)M" : "\(quotient).\(remainder)M"
            }
        
    }
}
