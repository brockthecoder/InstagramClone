//
//  NewProfilePageControlleViewController.swift
//  InstagramClone
//
//  Created by brock davis on 1/25/23.
//

import UIKit

class ProfilePageViewController: InstagramTabViewController, UIScrollViewDelegate {
    
    // Title bar components
    private let titleBar = UIView()
    private let usernameButton = UIButton()
    private let otherAccountNotificationsLabel = UILabel()
    private let contentCreationButton = UIButton()
    private let menuButton = UIButton()

    // Used to page between content galleries
    private let galleryPagingView = UIScrollView()
    private var galleryPagingObserveToken: NSKeyValueObservation!
    
    // Contains profile picture, metrics, bio, action buttons, etc.
    private let profileDetailsVC = ProfileDetailsViewController()
    private var detailsViewTopConstraint: NSLayoutConstraint!
    
    // Contains the scrollable story highlight reels
    private let storyHighlightReelsVC = StoryHighlightReelsViewController()

    // Gallery Tab Bar
    private let galleryTabBar = UIView()
    private let galleryTabIndicator = UIView()
    private var galleryTabIndicatorLeadingConstraint: NSLayoutConstraint!
    private let galleryTabButtons: [UIButton]
    private let galleryVCs: [GalleryViewController]
    private var galleryContentOffsetObserveToken: NSKeyValueObservation!
    private var currentGalleryTabIndex = 0 {
        didSet {
            self.view.removeGestureRecognizer(self.galleryVCs[oldValue].collectionView.panGestureRecognizer)
            self.view.addGestureRecognizer(self.galleryVCs[self.currentGalleryTabIndex].collectionView.panGestureRecognizer)
            self.galleryContentOffsetObserveToken = self.galleryVCs[self.currentGalleryTabIndex].collectionView.observe(\.contentOffset) { collectionView, _ in
                self.galleryContentOffsetChanged(collectionView: collectionView)
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        
        let user = ActiveUser.loggedIn.first!
        
        // Visible galleries are variable by user
        var tabIconButtons = [UIButton]()
        var galleryVCs = [GalleryViewController]()
        
        let tabCount: CGFloat = {
            // Always have postsw gallery and tagged-in gallery
            var count: CGFloat = 2
            if !user.subscriberPosts.isEmpty { count += 1}
            if !user.reels.isEmpty { count += 1}
            return count
        }()
        // Used to draw background images for tab buttons
        let tabButtonSize = CGSize(width: Configurations.tabWidth(numberOfTabs: tabCount), height: Configurations.galleryTabBarHeight)
        
        // Posts gallery tab
        galleryVCs.append(PostGalleryViewController())
        let postsTabButton = UIButton()
        postsTabButton.setBackgroundImage(Configurations.tabButtonBackgroundImage(forIcon: Configurations.postsTabIcon, size: tabButtonSize), for: .normal)
        postsTabButton.backgroundColor = Configurations.selectedTabColor
        tabIconButtons.append(postsTabButton)
        
        // Subscriber post gallery tab
        if !user.subscriberPosts.isEmpty {
            galleryVCs.append(SubscriberPostGalleryViewController())
            let subscriberPostsTabButton = UIButton()
            subscriberPostsTabButton.setBackgroundImage(Configurations.tabButtonBackgroundImage(forIcon: Configurations.subscribersTabIcon, size: tabButtonSize), for: .normal)
            subscriberPostsTabButton.backgroundColor = Configurations.unselectedTabsColor
            tabIconButtons.append(subscriberPostsTabButton)
        }
        
        // Reels gallery tab
        if !user.reels.isEmpty {
            galleryVCs.append(ReelsGalleryViewController())
            let reelsTabButton = UIButton()
            reelsTabButton.setBackgroundImage(Configurations.tabButtonBackgroundImage(forIcon: Configurations.reelsTabIcon, size: tabButtonSize), for: .normal)
            reelsTabButton.backgroundColor = Configurations.unselectedTabsColor
            tabIconButtons.append(reelsTabButton)
        }
        
        // Tagged-In gallery tab
        galleryVCs.append(TaggedInGalleryViewController())
        let taggedInTabButton = UIButton()
        taggedInTabButton.setBackgroundImage(Configurations.tabButtonBackgroundImage(forIcon: Configurations.taggedInTabIcon, size: tabButtonSize), for: .normal)
        taggedInTabButton.backgroundColor = Configurations.unselectedTabsColor
        tabIconButtons.append(taggedInTabButton)
        
        // Set instance properties
        self.galleryTabButtons = tabIconButtons
        self.galleryVCs = galleryVCs
        
        super.init(selectedTabIcon: Configurations.tabBarImage(profileImage: user.profilePicture, selected: true), unselectedTabIcon: Configurations.tabBarImage(profileImage: user.profilePicture, selected: false), hasNotification: false)
        self.view.backgroundColor = .black
        
        // Title Bar
        self.titleBar.translatesAutoresizingMaskIntoConstraints = false
        self.titleBar.backgroundColor = Configurations.titleBarColor
        self.view.addSubview(self.titleBar) {
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.view.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: Configurations.titleBarHeight)
            ])
        }
        
        // Menu button
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.setBackgroundImage(Configurations.mbIcon, for: .normal)
        self.titleBar.addSubview(self.menuButton)
        NSLayoutConstraint.activate([
            self.menuButton.trailingAnchor.constraint(equalTo: self.titleBar.trailingAnchor, constant: -Configurations.mbTrailingSpacing),
            self.menuButton.topAnchor.constraint(equalTo: self.titleBar.topAnchor, constant: Configurations.mbTopSpacing),
            self.menuButton.widthAnchor.constraint(equalToConstant: Configurations.mbSize.width),
            self.menuButton.heightAnchor.constraint(equalToConstant: Configurations.mbSize.height)
        ])
        
        // Content creation button
        self.contentCreationButton.translatesAutoresizingMaskIntoConstraints = false
        self.contentCreationButton.setBackgroundImage(Configurations.ccbIcon, for: .normal)
        self.titleBar.addSubview(self.contentCreationButton)
        NSLayoutConstraint.activate([
            self.contentCreationButton.trailingAnchor.constraint(equalTo: self.menuButton.leadingAnchor, constant: -Configurations.ccbTrailingSpacing),
            self.contentCreationButton.centerYAnchor.constraint(equalTo: self.menuButton.centerYAnchor),
            self.contentCreationButton.widthAnchor.constraint(equalToConstant: Configurations.ccbIconSize.width),
            self.contentCreationButton.heightAnchor.constraint(equalToConstant: Configurations.ccbIconSize.height)
        ])
        
        // Username Button
        self.usernameButton.translatesAutoresizingMaskIntoConstraints = false
        let usernameText = NSMutableAttributedString(string: user.username, attributes: Configurations.usernameTextAttributes)
        if user.isVerified {
            usernameText.append(NSAttributedString(string: " ", attributes: Configurations.usernameTextAttributes))
            let attachment = NSTextAttachment(image: Configurations.verifiedIcon)
            attachment.bounds = CGRect(x: 0, y: 1, width: Configurations.verifiedIconSize.width, height: Configurations.verifiedIconSize.height)
            usernameText.append(NSAttributedString(attachment: attachment))
        }
        self.usernameButton.setAttributedTitle(usernameText, for: .normal)
        self.titleBar.addSubview(self.usernameButton)
        NSLayoutConstraint.activate([
            self.usernameButton.leadingAnchor.constraint(equalTo: self.titleBar.leadingAnchor, constant: Configurations.usernameButtonLeadingSpacing),
            self.usernameButton.centerYAnchor.constraint(equalTo: self.menuButton.centerYAnchor)
        ])
        
        // Other account notifications label
        self.otherAccountNotificationsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.otherAccountNotificationsLabel.attributedText = NSAttributedString(string: "9+", attributes: Configurations.oanlTextAttributes)
        self.otherAccountNotificationsLabel.layer.masksToBounds = true
        self.otherAccountNotificationsLabel.layer.cornerRadius = Configurations.oanlCornerRadius
        self.otherAccountNotificationsLabel.backgroundColor = Configurations.oanlBackgroundColor
        self.titleBar.addSubview(self.otherAccountNotificationsLabel)
        NSLayoutConstraint.activate([
            self.otherAccountNotificationsLabel.leadingAnchor.constraint(equalTo: self.usernameButton.trailingAnchor, constant: Configurations.oanlLeadingSpacing),
            self.otherAccountNotificationsLabel.centerYAnchor.constraint(equalTo: self.usernameButton.centerYAnchor, constant: Configurations.oanlCenterYOffset),
            self.otherAccountNotificationsLabel.widthAnchor.constraint(equalToConstant: Configurations.oanlSize.width),
            self.otherAccountNotificationsLabel.heightAnchor.constraint(equalToConstant: Configurations.oanlSize.height)
        ])
        
        // Details View
        self.addChild(self.profileDetailsVC)
        let detailsView = self.profileDetailsVC.view!
        self.view.insertSubview(detailsView, below: self.titleBar) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.detailsViewTopConstraint = $0.topAnchor.constraint(equalTo: self.titleBar.bottomAnchor)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.detailsViewTopConstraint
                // Size is defined with size constraints by details VC to match content size
            ])
        }
        self.profileDetailsVC.didMove(toParent: self)
        
        // Story Hightlight Reels View
        self.addChild(self.storyHighlightReelsVC)
        let storyHighlightReelsView = self.storyHighlightReelsVC.view!
        self.view.insertSubview(storyHighlightReelsView, below: detailsView){
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
                $0.topAnchor.constraint(equalTo: detailsView.bottomAnchor)
                // Size constraints specified in highlight reels VC
            ])
        }
        self.storyHighlightReelsVC.didMove(toParent: self)
        
        // Galleries Tab Bar
        self.view.insertSubview(self.galleryTabBar, below: storyHighlightReelsView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .black
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: storyHighlightReelsView.leadingAnchor),
                $0.topAnchor.constraint(equalTo: storyHighlightReelsView.bottomAnchor),
                $0.trailingAnchor.constraint(equalTo: storyHighlightReelsView.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: Configurations.galleryTabBarHeight)
            ])
        }
        
        // Gallery Tab Icons
        var prevTabButton: UIButton?
        for galleryTabButton in self.galleryTabButtons {
            galleryTabButton.addTarget(self, action: #selector(self.galleryTabButtonWasTapped(button:)), for: .touchUpInside)
            self.galleryTabBar.addSubview(galleryTabButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: prevTabButton == nil ? self.galleryTabBar.leadingAnchor : prevTabButton!.trailingAnchor),
                    $0.topAnchor.constraint(equalTo: self.galleryTabBar.topAnchor)
                ])
                prevTabButton = galleryTabButton
            }
        }
        
        // Gallery tab indicator bar
        self.galleryTabBar.insertSubview(self.galleryTabIndicator, aboveSubview: prevTabButton!) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.galleryTabIndicatorColor
            self.galleryTabIndicatorLeadingConstraint = $0.leadingAnchor.constraint(equalTo: self.galleryTabBar.leadingAnchor, constant: 0)
            NSLayoutConstraint.activate([
                self.galleryTabIndicatorLeadingConstraint,
                $0.bottomAnchor.constraint(equalTo: self.galleryTabBar.bottomAnchor),
                $0.widthAnchor.constraint(equalToConstant: Configurations.tabIndicatorWidth(numberOfTabs: CGFloat(self.galleryTabButtons.count))),
                $0.heightAnchor.constraint(equalToConstant: Configurations.galleryTabIndicatorHeight)
            ])
        }
        
        // Paging scroll view for galleries
        self.galleryPagingView.showsHorizontalScrollIndicator = false
        self.galleryPagingView.isPagingEnabled = true
        self.galleryPagingView.clipsToBounds = false
        self.galleryPagingView.delegate = self
        self.view.insertSubview(self.galleryPagingView, below: self.galleryTabBar) {
            $0.backgroundColor = .black
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -Configurations.interGallerySpacing / 2),
                $0.topAnchor.constraint(equalTo: self.galleryTabBar.bottomAnchor),
                $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: Configurations.interGallerySpacing / 2),
                $0.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: (Configurations.titleBarHeight + Configurations.galleryTabBarHeight) * -1),
                self.galleryPagingView.contentLayoutGuide.heightAnchor.constraint(equalTo: self.galleryPagingView.frameLayoutGuide.heightAnchor),
                self.galleryPagingView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.galleryPagingView.frameLayoutGuide.widthAnchor, multiplier: tabCount)
            ])
        }
        
        // Observe horizontal scroll view to update tab indicator and animate tab icons
        self.galleryPagingObserveToken = self.galleryPagingView.observe(\.contentOffset) { _, _ in
            
            // Adjust tab indicator position
            let newIndicatorXOrigin = self.galleryPagingView.contentOffset.x * (Configurations.tabWidth(numberOfTabs: CGFloat(self.galleryTabButtons.count)) / self.galleryPagingView.frame.width)
            self.galleryTabIndicatorLeadingConstraint.constant = newIndicatorXOrigin
            
            // Adjust selected tab index conditionally
            let currentIndex = self.currentGalleryTabIndex
            let newIndex: Int
            if newIndicatorXOrigin > self.galleryTabButtons[currentIndex].frame.midX && currentIndex < (self.galleryTabButtons.count - 1) {
                newIndex = self.currentGalleryTabIndex + 1
            } else if (newIndicatorXOrigin + self.galleryTabIndicator.frame.width) < self.galleryTabButtons[currentIndex].frame.midX && currentIndex > 0 {
                newIndex = self.currentGalleryTabIndex - 1
            } else {
                // No updates or animations needed
                return
            }
            
            self.currentGalleryTabIndex = newIndex
            
            // Animate icon colors
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut]) {
                self.galleryTabButtons[currentIndex].backgroundColor = Configurations.unselectedTabsColor
            }
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn]) {
                self.galleryTabButtons[newIndex].backgroundColor = Configurations.selectedTabColor
            }
        }
        
        // Galleries
        var prevGallery: UIView?
        for galleryVC in galleryVCs {
            self.addChild(galleryVC)
            galleryVC.collectionView.showsVerticalScrollIndicator = true
            let galleryView = galleryVC.view!
            
            self.galleryPagingView.addSubview(galleryView) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: prevGallery == nil ? self.galleryPagingView.contentLayoutGuide.leadingAnchor : prevGallery!.trailingAnchor, constant: prevGallery == nil ? Configurations.interGallerySpacing / 2 : Configurations.interGallerySpacing),
                    $0.topAnchor.constraint(equalTo: self.titleBar.bottomAnchor),
                    $0.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                    $0.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
            }
            prevGallery = galleryView
            galleryVC.didMove(toParent: self)
        }
        self.view.addGestureRecognizer(self.galleryVCs.first!.collectionView.panGestureRecognizer)
        self.galleryContentOffsetObserveToken = self.galleryVCs.first!.collectionView.observe(\.contentOffset) { collectionView, _ in
            self.galleryContentOffsetChanged(collectionView: collectionView)
        }
        
        DispatchQueue.main.delay(3) {
            self.hasNotification = ActiveUser.loggedIn.first!.activityNotifications.totalUnseen > 0
        }
        
    }
    
    private func galleryContentOffsetChanged(collectionView: UICollectionView) {
        let maxOffset = self.profileDetailsVC.view.frame.height + self.storyHighlightReelsVC.view.frame.height
        self.detailsViewTopConstraint.constant = max(-maxOffset, collectionView.contentOffset.y * -1)
        for otherCollectionView in self.galleryVCs.map({$0.collectionView}).filter({$0 != collectionView}) {
            otherCollectionView.contentOffset.y = min(maxOffset, collectionView.contentOffset.y)
        }
    }
    
    @objc private func galleryTabButtonWasTapped(button: UIButton) {
        
        self.prepareForGalleryChange()
        let tabIndex = self.galleryTabButtons.firstIndex(of: button)!
        
        guard tabIndex != self.currentGalleryTabIndex else {
            let currentCollectionView = self.galleryVCs[tabIndex].collectionView
            currentCollectionView.setContentOffset(CGPoint(x: currentCollectionView.contentOffset.x, y: self.profileDetailsVC.view.frame.height + self.storyHighlightReelsVC.view.frame.height), animated: true)
            return
        }
        
        self.galleryPagingView.setContentOffset(CGPoint(x: CGFloat(tabIndex) * self.galleryPagingView.frame.width, y: self.galleryPagingView.contentOffset.y), animated: true)
        self.currentGalleryTabIndex = tabIndex
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
        let galleryYOriginOffset = self.profileDetailsVC.view.frame.height + self.storyHighlightReelsVC.view.frame.height + self.galleryTabBar.frame.height
        for galleryVC in galleryVCs {
            galleryVC.profileContentHeight = galleryYOriginOffset
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        prepareForGalleryChange()
    }
    
    private func prepareForGalleryChange() {
        let currentGalleryView = galleryVCs[self.currentGalleryTabIndex].collectionView
        if currentGalleryView.contentOffset.y < 0 {
            currentGalleryView.refreshControl?.endRefreshing()
            currentGalleryView.setContentOffset(.zero, animated: false)
        }
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    // Title Bar Configurations
    static let titleBarColor = UIColor(named: "ProfilePage/TitleBar/backgroundColor")!
    static let titleBarHeight = screenWidth * 0.264285
    
    // Username Button Configurations
    static let usernameButtonLeadingSpacing = screenWidth * 0.040953
    static let usernameTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/TitleBar/usernameButton/textColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.06132, weight: .bold)
    ]
    static let verifiedIconSize = CGSize.sqaure(size: (usernameTextAttributes[.font] as! UIFont).xHeight * 1.15)
    static let verifiedIcon = UIImage(named: "ProfilePage/TitleBar/usernameButton/verifiedIcon")!
    
    // Other Account Notifications Label Configurations (oanl)
    static let oanlLeadingSpacing = screenWidth * 0.01
    static let oanlCenterYOffset = screenWidth * 0.0025 * 0
    static let oanlBackgroundColor = UIColor(named: "ProfilePage/TitleBar/otherAccountNotificationsLabel/backgroundColor")!
    static let oanlSize = CGSize(width: screenWidth * 0.05527564, height: screenWidth * 0.0448166)
    static let oanlCornerRadius = oanlSize.width * 0.4
    static let oanlParagraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.firstLineHeadIndent = 2
        return style
    }()
    static let oanlTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/TitleBar/otherAccountNotificationsLabel/textColor")!,
        .paragraphStyle: oanlParagraphStyle,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.036, weight: .semibold),
        .kern: 0.1
    ]
    
    // Content Creation Button Configurations (ccb)
    static let ccbTrailingSpacing = screenWidth * 0.0680272
    static let ccbIcon = UIImage(named: "ProfilePage/TitleBar/contentCreationButton/icon")!.withTintColor(UIColor(named: "ProfilePage/TitleBar/contentCreationButton/iconFillColor")!)
    static let ccbIconSize = CGSize.sqaure(size: screenWidth * 0.056802)
    
    // Menu Button Configurations (mb)
    static let mbTopSpacing = screenWidth * 0.180492
    static let mbTrailingSpacing = screenWidth * 0.04506365
    static let mbIcon = UIImage(named: "ProfilePage/TitleBar/menuButton/icon")!.withTintColor(UIColor(named: "ProfilePage/TitleBar/menuButton/iconFillColor")!)
    static let mbSize = CGSize(width: screenWidth * 0.05161, height: screenWidth * 0.0413265)
    
    // Gallery Tab Bar Configurations
    static let galleryTabBarHeight: CGFloat = 44
    static let interGalleryTabSpacing: CGFloat = 1
    static let galleryTabIndicatorHeight: CGFloat = 1
    static let galleryTabIndicatorColor = UIColor(named: "ProfilePage/GalleryTabBar/selectionBarColor")!
    static func tabIndicatorWidth(numberOfTabs: CGFloat) -> CGFloat {
        (screenWidth / numberOfTabs) - (((numberOfTabs - 1) * interGalleryTabSpacing) / numberOfTabs)
    }
    static func tabWidth(numberOfTabs: CGFloat) -> CGFloat {
        tabIndicatorWidth(numberOfTabs: numberOfTabs) + interGalleryTabSpacing
    }
    static let tabIconsVerticalCenterOffset = screenWidth * 0.00084817642069550466
    static let postsTabIconSize = CGSize.sqaure(size: 22)
    static let subscribersTabIconSize = CGSize(width: 22, height: 17)
    static let reelsTabIconSize = CGSize.sqaure(size: 22)
    static let taggedInTabIconSize = CGSize.sqaure(size: 22)
    static let postsTabIcon = UIImage(named: "ProfilePage/GalleryTabBar/postsIcon")!.resizedTo(size: postsTabIconSize)
    static let subscribersTabIcon = UIImage(named: "ProfilePage/GalleryTabBar/subscriberExclusivesIcon")!.resizedTo(size: subscribersTabIconSize)
    static let reelsTabIcon = UIImage(named: "ProfilePage/GalleryTabBar/reelsIcon")!.resizedTo(size: reelsTabIconSize)
    static let taggedInTabIcon = UIImage(named: "ProfilePage/GalleryTabBar/taggedInIcon")!.resizedTo(size: taggedInTabIconSize)
    static let selectedTabColor = UIColor(named: "ProfilePage/GalleryTabBar/selectedIconFillColor")!
    static let unselectedTabsColor = UIColor(named: "ProfilePage/GalleryTabBar/unselectedIconFillColor")!
    
    static func tabButtonBackgroundImage(forIcon icon: UIImage, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.black.cgColor)
            context.fill([CGRect(origin: .zero, size: size)])
            let iconRect = CGRect(x: (size.width - icon.size.width) / 2, y: (size.height - icon.size.height) / 2, width: icon.size.width, height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .destinationOut, alpha: 1)
        }
    }
    
    // Galleries Configurations
    static let interGallerySpacing: CGFloat = 8
    
    
    static func tabBarImage(profileImage: UIImage, selected: Bool) -> UIImage {
        let profilePictureSize = CGSize.sqaure(size: 67.0 / 3.0)
        let imageSize = selected ? CGSize.sqaure(size: 80.0 / 3.0) : profilePictureSize
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            
            if selected {
                context.saveGState()
                UIColor.white.setFill()
                context.addEllipse(in: CGRect(origin: .zero, size: imageSize))
                context.addEllipse(in: CGRect(x: imageSize.width * 0.05, y: imageSize.width * 0.05, width: imageSize.width - (imageSize.width * 0.1), height: imageSize.width - (imageSize.width * 0.1)))
                context.clip(using: .evenOdd)
                context.fill([CGRect(origin: .zero, size: imageSize)])
                context.restoreGState()
            }
            let profilePictureRect = CGRect(x: (imageSize.width / 2) - (profilePictureSize.width / 2), y: (imageSize.height / 2) - (profilePictureSize.height / 2), width: profilePictureSize.width, height: profilePictureSize.height)
            context.addEllipse(in: profilePictureRect)
            context.clip()
            profileImage.draw(in: profilePictureRect)
        }
    }
}
