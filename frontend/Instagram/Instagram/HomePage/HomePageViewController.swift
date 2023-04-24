//
//  HomeFeedPageViewController.swift
//  InstagramClone
//
//  Created by brock davis on 9/28/22.
//

import UIKit

class HomePageViewController: InstagramTabViewController, HomePageFeedControllerDelegate {

    private let headerView = UIView()
    private let headerViewDivider = UIView()
    private let headerViewDividerAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    private let igLogoButton = UIButton()
    private let activityButtton = UIButton()
    private let messengerButton = UIButton()
    private let messengerNotificationsLabel = UILabel()
    private let igButtonMenu = IgButtonMenuView()
    private let igMenuDismissView = UIView()
    private let igMenuDismissGR = UITapGestureRecognizer()
    private let homeFeedVC: HomePageFeedController
    
    var activityButtonHidden: Bool = false {
        didSet {
            self.activityButtton.isHidden = activityButtonHidden
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        
        let storiesVC = StoriesViewController()
        self.homeFeedVC = HomePageFeedController(storiesViewController: storiesVC)
        let viewWidth = UIScreen.main.bounds.width
        super.init(selectedTabIcon: Configurations.selectedTabIcon, unselectedTabIcon: Configurations.unselectedTabIcon, hasNotification: false)

        // Add the header view
        self.headerView.backgroundColor = .black
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.headerView)
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2634)
        ])
        
        // Add the header view divider
        self.headerViewDivider.translatesAutoresizingMaskIntoConstraints = false
        self.headerViewDivider.alpha = 0
        self.headerViewDivider.backgroundColor = UIColor(named: "HomePage/StoriesCollectionBottomDividerColor")!
        self.headerView.addSubview(self.headerViewDivider)
        NSLayoutConstraint.activate([
            self.headerViewDivider.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.headerViewDivider.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.headerViewDivider.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.headerViewDivider.heightAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.001)
        ])
        
        // Add IG logo button
        self.igLogoButton.setBackgroundImage(Configurations.igLogoButtonBackgroundImage(withChevron: false), for: .normal)
        self.igLogoButton.setBackgroundImage(Configurations.igLogoButtonBackgroundImage(withChevron: true), for: .selected)
        self.igLogoButton.translatesAutoresizingMaskIntoConstraints = false
        self.igLogoButton.addTarget(self, action: #selector(self.toggleIgMenu), for: .touchUpInside)
        headerView.addSubview(self.igLogoButton)
        NSLayoutConstraint.activate([
            self.igLogoButton.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: Configurations.instagramLogoButtonLeadingSpacing),
            self.igLogoButton.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: Configurations.instagramLogoButtonTopSpacing)
        ])
        
        // Add Messenger button
        self.messengerButton.setBackgroundImage(Configurations.messengerIcon, for: .normal)
        self.messengerButton.addTarget(self, action: #selector(self.messengerButtonTapped), for: .touchUpInside)
        self.headerView.addSubview(self.messengerButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -Configurations.messengerIconTrailingSpacing),
                $0.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: Configurations.messengerIconTopSpacing)
            ])
        }
        
        // Add the messenger notifications label
        let user = ActiveUser.loggedIn.first!
        self.messengerNotificationsLabel.translatesAutoresizingMaskIntoConstraints = false
        let countText = String(user.messengerNotifications.totalMessages > 20 ? 20 : user.messengerNotifications.totalMessages)
        self.messengerNotificationsLabel.attributedText = NSAttributedString(string: countText, attributes: Configurations.messengerNotificationsTextAttributes)
        self.messengerNotificationsLabel.isHidden = user.messengerNotifications.totalMessages < 1
        self.messengerNotificationsLabel.backgroundColor = Configurations.messengerNotificationCircleFillColor
        self.messengerNotificationsLabel.layer.masksToBounds = true
        self.messengerNotificationsLabel.layer.cornerRadius = Configurations.messengerNotificationCircleSize.width / 2
        self.messengerNotificationsLabel.layer.cornerCurve = .continuous
        self.messengerButton.addSubview(self.messengerNotificationsLabel)
        NSLayoutConstraint.activate([
            self.messengerNotificationsLabel.leadingAnchor.constraint(equalTo: self.messengerButton.leadingAnchor, constant: Configurations.messengerNotificationCircleOffset.width),
            self.messengerNotificationsLabel.bottomAnchor.constraint(equalTo: self.messengerButton.bottomAnchor, constant: -Configurations.messengerNotificationCircleOffset.height),
            self.messengerNotificationsLabel.widthAnchor.constraint(equalToConstant: Configurations.messengerNotificationCircleSize.width),
            self.messengerNotificationsLabel.heightAnchor.constraint(equalToConstant: Configurations.messengerNotificationCircleSize.height)
        ])
        
        // Add Activity button
        self.activityButtton.translatesAutoresizingMaskIntoConstraints = false
        self.activityButtton.setBackgroundImage(Configurations.activityButtonBackgroundImage(withNotifications: user.activityNotifications.totalUnseen > 0), for: .normal)
        self.activityButtton.addTarget(self, action: #selector(self.activityButtonTapped), for: .touchUpInside)
        self.headerView.addSubview(self.activityButtton)
        NSLayoutConstraint.activate([
            self.activityButtton.trailingAnchor.constraint(equalTo: self.messengerButton.leadingAnchor, constant: -Configurations.activityButtonTrailingSpacing),
            self.activityButtton.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: Configurations.activityButtonTopSpacing)
        ])
        
        // Add the home feed VC and its view
        self.homeFeedVC.delegate = self
        self.addChild(self.homeFeedVC)
        let homeFeedView = self.homeFeedVC.view!
        homeFeedView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(homeFeedView, belowSubview: self.headerView)
        NSLayoutConstraint.activate([
            homeFeedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            homeFeedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            homeFeedView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            homeFeedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.homeFeedVC.didMove(toParent: self)
        
        // Add the dismiss view and GR
        self.igMenuDismissView.translatesAutoresizingMaskIntoConstraints = false
        self.igMenuDismissView.backgroundColor = .clear
        self.igMenuDismissView.isHidden = true
        self.view.addSubview(self.igMenuDismissView)
        NSLayoutConstraint.activate([
            self.igMenuDismissView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.igMenuDismissView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.igMenuDismissView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.igMenuDismissView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.igMenuDismissView.addGestureRecognizer(self.igMenuDismissGR)
        self.igMenuDismissGR.addTarget(self, action: #selector(self.toggleIgMenu))
        
        // Add the IG Button Menu
        self.igButtonMenu.translatesAutoresizingMaskIntoConstraints = false
        self.igButtonMenu.isHidden = true
        self.igMenuDismissView.addSubview(self.igButtonMenu)
        NSLayoutConstraint.activate([
            self.igButtonMenu.leadingAnchor.constraint(equalTo: self.igLogoButton.leadingAnchor, constant: viewWidth / 100),
            self.igButtonMenu.topAnchor.constraint(equalTo: self.igLogoButton.bottomAnchor, constant: 3),
            self.igButtonMenu.trailingAnchor.constraint(equalTo: self.igLogoButton.trailingAnchor, constant: viewWidth / 20),
            self.igButtonMenu.heightAnchor.constraint(equalToConstant: 87)
        ])
    }
    
    
    @objc private func toggleIgMenu() {
        self.igMenuDismissView.isHidden.toggle()
        
        UIView.transition(with: self.igButtonMenu, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseInOut]) {
            self.igLogoButton.isSelected = true
            self.igButtonMenu.isHidden.toggle()
        }
        
    }
    
    @objc private func activityButtonTapped() {
        InstagramTabBarController.shared.transitionToPage(page: .activity)
    }
    
    @objc private func messengerButtonTapped() {
        PrimaryPageViewController.shared.transitionTo(page: .messaging)
    }
    
    func homePageFeedControllerDidRefresh(_ viewController: HomePageFeedController) {
        if self.igLogoButton.isSelected {
            UIView.transition(with: self.igLogoButton, duration: 0.25, options: [.transitionCrossDissolve, .curveEaseInOut]) {
                self.igLogoButton.isSelected = false
            }
        }
    }
    
    func homePageFeedViewDidScroll(_ viewController: HomePageFeedController, newContentOffset contentOffset: CGPoint) {
        self.headerViewDividerAnimator.fractionComplete = min(1, max(0, contentOffset.y / 50))
        if !self.igLogoButton.isSelected {
            UIView.transition(with: self.igLogoButton, duration: 0.25, options: [.transitionCrossDissolve, .curveEaseInOut]) {
                self.igLogoButton.isSelected = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.headerViewDivider.alpha = 0
        // Add the fading animation - Core Animation removes the animation when the view is removed from the window's hierarchy
        self.headerViewDividerAnimator.addAnimations {
            self.headerViewDivider.alpha = 1
        }
        self.headerViewDividerAnimator.fractionComplete = max(0, min(1, self.homeFeedVC.contentOffset.y / 50))
    }
}

private struct Configurations {
            
    static let tabIconFillColor = UIColor(named: "HomePage/tabIconFillColor")!
    static let tabIconSize = CGSize.sqaure(size: 22)
    static let selectedTabIcon = UIImage(named: "HomePage/selectedTabIcon")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    static let unselectedTabIcon = UIImage(named: "HomePage/unselectedTabIcon")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    
    static let instagramLogoButtonLeadingSpacing = 18.0
    static let instagramLogoButtonTopSpacing = 63.0
    
    static let instagramLogoSize = CGSize(width: 116, height: 33)
    static let instagramLogoColor = UIColor(named: "HomePage/Logo/fillColor")!
    static let instagramLogoImage = UIImage(named: "HomePage/Logo/vector")!.resizedTo(size: instagramLogoSize).withTintColor(instagramLogoColor)
    static let instagramLogoChevronSize = CGSize(width: 10, height: 6)
    static let instagramLogoChevronIcon = UIImage(named: "HomePage/Logo/chevronIcon")!.resizedTo(size: instagramLogoChevronSize).withTintColor(instagramLogoColor)
    static let instagramLogoChevronLeadingSpacing = 8.0
    static let instagramLogoChevronCenterYOffset = -5.0 / 3.0
    
    
    static let viewWidth = UIScreen.main.bounds.width
    
    static func igLogoButtonBackgroundImage(withChevron: Bool = false) -> UIImage {
        let imageSize = CGSize(width: instagramLogoSize.width + ( withChevron ? (instagramLogoChevronLeadingSpacing + instagramLogoChevronSize.width) : 0), height: instagramLogoSize.height)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            instagramLogoImage.draw(at: .zero)
            if withChevron {
                let chevronOrigin = CGPoint(x: instagramLogoSize.width + instagramLogoChevronLeadingSpacing, y: (instagramLogoSize.height / 2) - (instagramLogoChevronSize.height / 2) + instagramLogoChevronCenterYOffset)
                instagramLogoChevronIcon.draw(at: chevronOrigin)
            }
        }
    }
    
    static let messengerIconTrailingSpacing = 20.0
    static let messengerIconTopSpacing = 197.0 / 3.0
    static let messengerIconSize = CGSize.sqaure(size: 22)
    static let messengerIconFillColor = UIColor(named: "HomePage/Messaging/iconFillColor")!
    static let messengerIcon = UIImage(named: "HomePage/Messaging/icon")!.resizedTo(size: messengerIconSize).withTintColor(messengerIconFillColor)
    
    static let messengerNotificationCircleSize = CGSize.sqaure(size: 18)
    static let messengerNotificationCircleFillColor = UIColor(named: "HomePage/Messaging/notificationsFillColor")!
    static let messengerNotificationCircleOffset = CGSize(width: 13, height: 12)
    
    static let messengerNotificationsTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
        .paragraphStyle: NSParagraphStyle.centerAligned
    ]
    
    static let activityButtonTrailingSpacing = 70.0 / 3.0
    static let activityButtonTopSpacing = 190.0 / 3.0
    
    static let activityIconSize = CGSize(width: 23, height: 61.0 / 3.0)
    static let activityIconFillColor = UIColor(named: "HomePage/Activity/iconFillColor")!
    static let activityIcon = UIImage(named: "HomePage/Activity/icon")!.resizedTo(size: activityIconSize).withTintColor(activityIconFillColor)
    
    static let activityNotificationCircleSize = CGSize.sqaure(size: 34.0 / 3.0)
    static let activityNotificationRedCircleSize = CGSize.sqaure(size: 8)
    static let activityNotificationRedCircleColor = UIColor(named: "HomePage/Activity/notificationsFillColor")!
    static let activityNotificationCircleOffset = CGSize(width: 44.0 / 3.0, height: 12)
    
    static func activityButtonBackgroundImage(withNotifications: Bool = false) -> UIImage {
        let imageSize = CGSize(width: activityIconSize.width + activityNotificationCircleSize.width - (activityIconSize.width - activityNotificationCircleOffset.width), height: activityIconSize.height + activityNotificationCircleSize.height - (activityIconSize.height - activityNotificationCircleOffset.height))

        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            activityIcon.draw(at: CGPoint(x: 0, y: imageSize.height - activityIcon.size.height))
            
            if withNotifications {
                let context = UIGraphicsGetCurrentContext()!
                context.setFillColor(UIColor.black.cgColor)
                
                let outerNotificationCircleRect = CGRect(x: activityNotificationCircleOffset.width, y: (imageSize.height - activityNotificationCircleSize.height) - activityNotificationCircleOffset.height, width: activityNotificationCircleSize.width, height: activityNotificationCircleSize.height)
                context.fillEllipse(in: outerNotificationCircleRect)
                
                let innerNotificationCircleRect = CGRect(x: outerNotificationCircleRect.midX - (activityNotificationRedCircleSize.width / 2), y: outerNotificationCircleRect.midY - (activityNotificationRedCircleSize.height / 2), width: activityNotificationRedCircleSize.width, height: activityNotificationRedCircleSize.height)
                activityNotificationRedCircleColor.setFill()
                context.fillEllipse(in: innerNotificationCircleRect)
                
            }
        }
    }
}
