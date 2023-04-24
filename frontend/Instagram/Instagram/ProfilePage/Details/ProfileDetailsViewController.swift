//
//  ProfileDetailsViewController.swift
//  InstagramClone
//
//  Created by brock davis on 1/19/23.
//

import UIKit

class ProfileDetailsViewController: UIViewController {
    
    private let profilePictureView = ProfilePageProfilePictureView()
    private let postCountButton = UIButton()
    private let followerCountButton = UIButton()
    private let followingCountButton = UIButton()
    private let fullNameLabel = UILabel()
    private let accountCategoryButton = UIButton()
    private let biographyView = ProfileBioView()
    private let linkButton = UIButton()
    private let channelButton = UIButton()
    private let dashboardButton = UIButton()
    private let actionButtons: [UIButton]

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        let user = ActiveUser.loggedIn.first!
        
        self.actionButtons = user.contactInfoHidden ? [UIButton(), UIButton()] : [UIButton(), UIButton(), UIButton()]
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        
        // Profile Picture View
        self.profilePictureView.mode = user.hasPublicStory ? .unseenStory : .noStory
        self.profilePictureView.profilePicture = user.profilePicture
        self.profilePictureView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.profilePictureView)
        NSLayoutConstraint.activate([
            self.profilePictureView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.profilePictureViewLeadingSpacing),
            self.profilePictureView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
        
        var prevBottomAnchor = self.profilePictureView.bottomAnchor
        var prevElementKind: Configurations.Element = .pfp
        
        // Post count button
        self.postCountButton.translatesAutoresizingMaskIntoConstraints = false
        self.postCountButton.isUserInteractionEnabled = false
        self.postCountButton.titleLabel?.numberOfLines = 2
        self.postCountButton.setAttributedTitle(Configurations.formattedCountLabelText(for: user.postCount, title: "Posts"), for: .normal)
        self.view.addSubview(self.postCountButton)
        NSLayoutConstraint.activate([
            self.postCountButton.leadingAnchor.constraint(equalTo: self.profilePictureView.trailingAnchor, constant: Configurations.postCountLeadingSpacing),
            self.postCountButton.centerYAnchor.constraint(equalTo: self.profilePictureView.centerYAnchor, constant: Configurations.postCountCenterYOffset)
        ])
        
        // Followers count button
        self.followerCountButton.translatesAutoresizingMaskIntoConstraints = false
        self.followerCountButton.isUserInteractionEnabled = false
        self.followerCountButton.titleLabel?.numberOfLines = 2
        self.followerCountButton.setAttributedTitle(Configurations.formattedCountLabelText(for: user.followerCount, title: "Followers"), for: .normal)
        self.view.addSubview(self.followerCountButton)
        NSLayoutConstraint.activate([
            self.followerCountButton.leadingAnchor.constraint(equalTo: self.postCountButton.trailingAnchor, constant: Configurations.followersCountLeadingSpacing),
            self.followerCountButton.centerYAnchor.constraint(equalTo: self.postCountButton.centerYAnchor)
        ])
        
        // Following count button
        self.followingCountButton.translatesAutoresizingMaskIntoConstraints = false
        self.followingCountButton.titleLabel?.numberOfLines = 2
        self.followingCountButton.isUserInteractionEnabled = false
        self.followingCountButton.setAttributedTitle(Configurations.formattedCountLabelText(for: user.followingCount, title: "Following"), for: .normal)
        self.view.addSubview(self.followingCountButton)
        NSLayoutConstraint.activate([
            self.followingCountButton.leadingAnchor.constraint(equalTo: self.followerCountButton.trailingAnchor, constant: Configurations.followingCountLeadingSpacing),
            self.followingCountButton.centerYAnchor.constraint(equalTo: self.followerCountButton.centerYAnchor)
        ])
        
        // Full name label
        self.fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.fullNameLabel.attributedText = NSAttributedString(string: user.fullName, attributes: Configurations.fullNameTextAttributes)
        self.view.addSubview(self.fullNameLabel)
        NSLayoutConstraint.activate([
            self.fullNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.fullNameLeadingSpacing),
            self.fullNameLabel.topAnchor.constraint(equalTo: prevBottomAnchor, constant: Configurations.fullNameTopSpacing)
        ])
        prevBottomAnchor = self.fullNameLabel.bottomAnchor
        prevElementKind = .fullName
        
        // Account category button
        if !user.accountCategoryHidden {
            self.accountCategoryButton.translatesAutoresizingMaskIntoConstraints = false
            self.accountCategoryButton.isUserInteractionEnabled = false
            self.accountCategoryButton.setAttributedTitle(NSAttributedString(string: user.accountCategory, attributes: Configurations.accountCategoryTextAttributes), for: .normal)
            self.view.addSubview(self.accountCategoryButton)
            NSLayoutConstraint.activate([
                self.accountCategoryButton.leadingAnchor.constraint(equalTo: self.fullNameLabel.leadingAnchor),
                self.accountCategoryButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: Configurations.accountCategoryTopSpacing)
            ])
            prevBottomAnchor = self.accountCategoryButton.bottomAnchor
            prevElementKind = .accountCategory
        }
        
        // Biography view
        if let bio = user.bio {
            self.biographyView.backgroundColor = .red
            self.biographyView.translatesAutoresizingMaskIntoConstraints = false
            self.biographyView.biography = bio
            self.view.addSubview(self.biographyView)
            NSLayoutConstraint.activate([
                self.biographyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.biographyViewLeadingSpacing),
                self.biographyView.topAnchor.constraint(equalTo: prevBottomAnchor, constant: Configurations.biographyViewTopSpacing)
            ])
            prevBottomAnchor = self.biographyView.bottomAnchor
            prevElementKind = .bio
        }
        
        // Link button
        if let link = user.link {
            let linkIcon = NSTextAttachment(image: Configurations.linkIconWithSpacing)
            linkIcon.bounds = CGRect(origin: CGPoint(x: 0, y: Configurations.linkIconYOffset), size: Configurations.linkIconWithSpacing.size)
            let attributedLink = NSMutableAttributedString(attachment: linkIcon)
            attributedLink.append(NSAttributedString(string: link, attributes: Configurations.linkTextAttributees))
            self.linkButton.setAttributedTitle(attributedLink, for: .normal)
            self.linkButton.titleLabel?.lineBreakMode = .byTruncatingTail
            self.linkButton.contentHorizontalAlignment = .left
            self.view.addSubview(self.linkButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.biographyView.leadingAnchor, constant: Configurations.linkButtonLeadingSpacing),
                    $0.topAnchor.constraint(equalTo: prevBottomAnchor, constant: Configurations.linkButtonTopSpacing),
                    $0.widthAnchor.constraint(equalToConstant: Configurations.linkButtonWidth)
                ])
            }
            prevBottomAnchor = self.linkButton.bottomAnchor
            prevElementKind = .link
        }
        
        if let channel = user.channel, user.link == nil {
            let channelIcon = NSTextAttachment(image: Configurations.channelIconWithSpacing)
            channelIcon.bounds = CGRect(x: 0, y: Configurations.channelIconYOffset, width: Configurations.channelIconWithSpacing.size.width, height: Configurations.channelIconWithSpacing.size.height)
            let attributedChannelText = NSMutableAttributedString(attachment: channelIcon)
            attributedChannelText.append(NSAttributedString(string: channel, attributes: Configurations.channelTextAttributes))
            self.channelButton.setAttributedTitle(attributedChannelText, for: .normal)
            self.view.addSubview(self.channelButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.channelButtonLeadingSpacing),
                    $0.topAnchor.constraint(equalTo: prevBottomAnchor, constant: Configurations.channelButtonTopSpacing)
                ])
            }
            prevBottomAnchor = channelButton.bottomAnchor
            prevElementKind = .channel
        }
        
        // Dashboard button
        self.dashboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.dashboardButton.isUserInteractionEnabled = false
        self.dashboardButton.setBackgroundImage(Configurations.dashboardButtonBackgroundImage(accountsReached: user.accountsReachedThisMonth), for: .normal)
        self.dashboardButton.adjustsImageWhenHighlighted = false
        self.view.addSubview(self.dashboardButton)
        NSLayoutConstraint.activate([
            self.dashboardButton.leadingAnchor.constraint(equalTo: self.fullNameLabel.leadingAnchor),
            self.dashboardButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: Configurations.dashboardButtonTopSpacing(fromElement: prevElementKind))
        ])
        
        var actions = [NSAttributedString]()
        actions.append(NSAttributedString(string: "Edit profile", attributes: Configurations.actionButtonTextAttributes))
        if !user.subscriberPosts.isEmpty {
            if !user.contactInfoHidden {
                actions.append(NSAttributedString(string: "Email", attributes: Configurations.actionButtonTextAttributes))
            }
            actions.append(NSAttributedString(string: "Subscription", attributes: Configurations.newActionTextAttributes))
        } else {
            actions.append(NSAttributedString(string: "Share profile", attributes: Configurations.actionButtonTextAttributes))
            if !user.contactInfoHidden {
                actions.append(NSAttributedString(string: "Email", attributes: Configurations.actionButtonTextAttributes))
            }
        }
        
        let actionButtonSize = Configurations.actionButtonSize(buttonCount: self.actionButtons.count)
        var prev: UIButton? = nil
        for (ix, actionButton) in actionButtons.enumerated() {
            actionButton.isUserInteractionEnabled = false
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.setAttributedTitle(actions[ix], for: .normal)
            actionButton.backgroundColor = Configurations.actionButtonColor
            actionButton.layer.cornerRadius = Configurations.actionButtonCornerRadius
            actionButton.layer.masksToBounds = true
            self.view.addSubview(actionButton)
            NSLayoutConstraint.activate([
                actionButton.leadingAnchor.constraint(equalTo: prev == nil ? self.dashboardButton.leadingAnchor : prev!.trailingAnchor, constant: prev == nil ? 0 : Configurations.actionButtonSpacing),
                actionButton.topAnchor.constraint(equalTo: self.dashboardButton.bottomAnchor, constant: Configurations.editProfileButtonTopSpacing),
                actionButton.widthAnchor.constraint(equalToConstant: actionButtonSize.width),
                actionButton.heightAnchor.constraint(equalToConstant: actionButtonSize.height)
            ])
            prev = actionButton
        }
        
        // Define root view size
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.bottomAnchor.constraint(equalTo: self.actionButtons.first!.bottomAnchor),
            self.view.widthAnchor.constraint(equalToConstant: Configurations.screenWidth)
        ])
    }

}

private struct Configurations {
    
    enum Element {
        case pfp
        case fullName
        case accountCategory
        case bio
        case link
        case channel
    }
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let profilePictureViewLeadingSpacing = screenWidth * 0.0255
    
    static let postCountLeadingSpacing = screenWidth * 0.121
    
    static let postCountCenterYOffset = screenWidth * 0.0039
    
    static let numeralCountTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/countButtons/textColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.04555, weight: .semibold),
        .paragraphStyle: NSParagraphStyle.centerAligned
    ]
    
    static let countTitleAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/countButtons/textColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.04095, weight: .regular),
        .paragraphStyle: NSParagraphStyle.centerAligned,
        .baselineOffset: -0.6
    ]
    
    static let followersCountLeadingSpacing = screenWidth * 0.0635
    
    static let followingCountLeadingSpacing = screenWidth * 0.028
    
    static let nameTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/fullNameLabel/textColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.04197, weight: .semibold)
    ]
    
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
    
    static func formattedCountLabelText(for count: Int, title: String) -> NSAttributedString {
        let formattedString = NSMutableAttributedString(string: formattedCountNumber(forCount: count) + "\n", attributes: numeralCountTextAttributes)
        formattedString.append(NSAttributedString(string: title, attributes: countTitleAttributes))
        return formattedString
    }
    
    static let fullNameLeadingSpacing = screenWidth * 0.040565547158609
    
    static let fullNameTopSpacing = screenWidth * 0.017028435793045
    
    static let fullNameTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/fullNameLabel/textColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0408, weight: .semibold)
    ]
    
    static let accountCategoryTopSpacing = -screenWidth * 0.01295
    
    static let accountCategoryTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/accountCategoryButton/textColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0408, weight: .regular)
    ]
    
    static let biographyViewTopSpacing = -screenWidth * 0.013570822731128
    
    static let biographyViewLeadingSpacing = fullNameLeadingSpacing
    
    static let linkButtonTopSpacing = screenWidth * 0.0084817642069550466497031
    
    static let linkButtonWidth = screenWidth * 0.86
    
    static let linkButtonLeadingSpacing = screenWidth * 0.00169635284139100932994
    
    static let linkIconSize = CGSize.sqaure(size: screenWidth * 0.0424088210347752332485156)
    
    static let linkColor = UIColor(named: "ProfilePage/Details/linkLabel/linkColor")!
    
    static let linkIcon = UIImage(named: "ProfilePage/Details/linkLabel/linkIcon")!.withTintColor(linkColor).resizedTo(size: linkIconSize)
    static let linkIconWithSpacing = UIGraphicsImageRenderer(size: CGSize(width: linkIconSize.width + linkTextLeadingSpacing, height: linkIconSize.height)).image{ _ in
        linkIcon.draw(at: .zero)
    }
    static let linkIconYOffset = -3.0
    
    static let linkTextLeadingSpacing = 7.0
    static let linkTextAttributees: [NSAttributedString.Key: Any] = [
        .foregroundColor: linkColor,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0408, weight: .regular)
    ]
    
    static let channelButtonLeadingSpacing = 50.0 / 3.0
    
    static let channelButtonTopSpacing = 5.0 / 3.0
    
    static let channelTextLeadingSpacing = 20.0 / 3.0
    
    static let channelTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/Channel/textColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ]
    
    static let channelIconSize = CGSize(width: screenWidth * 0.0424088210347752332485156, height: screenWidth * 0.0390161153519932145886344)
    
    static let channelIcon = UIImage(named: "ProfilePage/Details/Channel/icon")!.withTintColor(UIColor(named: "ProfilePage/Details/Channel/iconFillColor")!).resizedTo(size: channelIconSize)
    static let channelIconWithSpacing = UIGraphicsImageRenderer(size: CGSize(width: channelIconSize.width + channelTextLeadingSpacing, height: channelIconSize.height)).image { _ in
        channelIcon.draw(at: .zero)
    }
    
    static let channelIconYOffset = -8.0 / 3.0
    
    static func dashboardButtonTopSpacing(fromElement: Element) -> CGFloat {
        switch fromElement {
        case .link:
            return screenWidth * 0.0070395309584393927056828
        case .bio:
            return screenWidth * 0.0265475886344359999999999
        case .fullName, .channel:
            return screenWidth * 0.0229007633587786259541984
        default:
            return 0.0
        }
    }
    
    static let dashboardButtonSize = CGSize(width: screenWidth * 0.918575063613232, height: screenWidth * 0.142493638676845)
    
    static let dashboardButtonColor = UIColor(named: "ProfilePage/Details/DashboardButton/backgroundColor")!
    
    static let dashboardButtonTitle = NSAttributedString(string: "Professional dashboard", attributes: [
        .foregroundColor: UIColor(named: "ProfilePage/Details/DashboardButton/titleColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
    ])
    
    static let dashboardButtonTitleLeadingSpacing = screenWidth * 0.03571642357930449534
    
    static let dashboardButtonTitleTopSpacing = screenWidth * 0.02544529262086513995
    
    static let accountsReachedTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/DashboardButton/descriptionColor")!,
        .font: UIFont.systemFont(ofSize: 14, weight: .regular)
    ]
    
    static let accountsReachedTextTopSpacing: CGFloat = 0
    
    static func dashboardButtonBackgroundImage(accountsReached: Int) -> UIImage {
        UIGraphicsImageRenderer(size: dashboardButtonSize).image { _  in
            dashboardButtonColor.setFill()
            let buttonRect = CGRect(origin: .zero, size: dashboardButtonSize)
            UIBezierPath(roundedRect: buttonRect, cornerRadius: dashboardButtonSize.width * 0.020356234096692).fill()
            let titleSize = dashboardButtonTitle.size()
            let titleRect = CGRect(x: dashboardButtonTitleLeadingSpacing, y: dashboardButtonTitleTopSpacing, width: titleSize.width, height: titleSize.height)
            dashboardButtonTitle.draw(in: titleRect)
            let accountsReachedString = NSAttributedString(string: "\(Configurations.formattedCountNumber(forCount: accountsReached)) accounts reached in the last 30 days.", attributes: accountsReachedTextAttributes)
            let subtitleSize = accountsReachedString.size()
            let subtitleRect = CGRect(x: titleRect.minX, y: titleRect.maxY + accountsReachedTextTopSpacing, width: subtitleSize.width, height: subtitleSize.height)
            accountsReachedString.draw(in: subtitleRect)
        }
    }
    
    static let editProfileButtonTopSpacing = screenWidth * 0.02205258693808312129
    static func actionButtonSize(buttonCount: Int) -> CGSize {
       return CGSize(width: ((dashboardButtonSize.width - (CGFloat(buttonCount - 1) * actionButtonSpacing)) / CGFloat(buttonCount)), height: screenWidth * 0.08142493638676844783)
    }
    static let actionButtonCornerRadius = screenWidth * 0.02120441051738761662
    static let actionButtonColor = UIColor(named: "ProfilePage/Details/ActionButtons/backgroundColor")!
    static let actionButtonTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/ActionButtons/textColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
        .paragraphStyle: NSParagraphStyle.centerAligned
    ]
    static let actionButtonSpacing = screenWidth * 0.01272264631043256997
    
    static let newActionTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/ActionButtons/textColor")!,
        .font: UIFont.systemFont(ofSize: 14, weight: .medium),
        .paragraphStyle: NSParagraphStyle.centerAligned
    ]
}
