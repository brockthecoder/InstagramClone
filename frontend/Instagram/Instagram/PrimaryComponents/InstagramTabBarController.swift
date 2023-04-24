//
//  UpdatedInstagramTabBarController.swift
//  InstagramClone
//
//  Created by brock davis on 10/9/22.
//

import UIKit

class InstagramTabBarController: UIViewController, InstagramTabBarDelegate, UIGestureRecognizerDelegate {
    
    static let shared = InstagramTabBarController()
    
    private let viewControllers: [InstagramTabViewController]
    let tabBar: InstagramTabBar
    private let divider = UIView()
    private let notificationsPopover = NotificationsPopoverView()
    private var popoverAppearanceAnimator: UIViewPropertyAnimator?
    private var popoverDisappearnaceAnimator: UIViewPropertyAnimator?
    @objc dynamic private(set) var currentVCIndex = 0
    private var notificationObservations: [NSKeyValueObservation]!

    required init(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        let homePageVC = HomePageViewController()
        homePageVC.activityButtonHidden = true
        let explorePageVC = ExplorePageViewController()
        let contentCreationVC = ContentCreationViewController.shared
        let activityPageVC = ActivityPageViewController()
        let profileVC = ProfilePageViewController()
        self.viewControllers = [homePageVC, explorePageVC, contentCreationVC,  activityPageVC, profileVC]
        let tabs = self.viewControllers.map { vc in
            (unselectedIcon: vc.unselectedTabIcon, selectedIcon: vc.selectedTabIcon, hasNotifications: vc.hasNotification)
        }
        self.tabBar = InstagramTabBar(tabs: tabs)
        super.init(nibName: nil, bundle: nil)
        self.tabBar.delegate = self
        self.tabBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tabBar)
        NSLayoutConstraint.activate([
            self.tabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tabBar.heightAnchor.constraint(equalToConstant: Configurations.tabBarHeight)
        ])
        
        self.view.addSubview(self.divider) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.dividerColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: Configurations.dividerHeight)
            ])
        }
        
        self.notificationsPopover.notifications = ActiveUser.loggedIn.first!.activityNotifications
        self.notificationsPopover.alpha = 0
        self.notificationsPopover.transform = CGAffineTransformMakeScale(0.5, 0.5)
        self.notificationsPopover.layer.shadowOpacity = 0.4
        self.notificationsPopover.layer.shadowRadius = 1.0
        self.notificationsPopover.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.view.addSubview(self.notificationsPopover) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: self.tabBar.tabButtons[3].centerXAnchor),
                $0.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor, constant: -Configurations.notificationsPopoverBottomSpacing)
            ])
        }
        
        self.notificationObservations = self.viewControllers.map { vc in
            vc.observe(\.hasNotification) { vc, _ in
                let tabIndex = self.viewControllers.firstIndex(of: vc)!
                self.tabBar.tabButtons[tabIndex].hasNotification = vc.hasNotification
                if tabIndex == 3 {
                    if vc.hasNotification && !(self.popoverDisappearnaceAnimator?.isRunning ?? false) && !(self.popoverAppearanceAnimator?.isRunning ?? false) {
                        self.popoverAppearanceAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7) {
                            self.notificationsPopover.alpha = 1
                            self.notificationsPopover.transform = .identity
                            self.popoverAppearanceAnimator?.addCompletion { position in
                                if position == .end {
                                    self.popoverDisappearnaceAnimator?.startAnimation(afterDelay: 12)
                                }
                            }
                        }
                        self.popoverDisappearnaceAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7) {
                            self.notificationsPopover.alpha = 0
                            self.notificationsPopover.transform = CGAffineTransformMakeScale(0.5, 0.5)
                        }
//                        self.popoverAppearanceAnimator?.startAnimation()
                    } else if !vc.hasNotification && self.notificationsPopover.layer.presentation()!.opacity != 0 {
                        if let popoverAppearanceAnimator = self.popoverAppearanceAnimator, popoverAppearanceAnimator.isRunning {
                            popoverAppearanceAnimator.stopAnimation(true)
                        }
                        if let popoverDisappearnaceAnimator = self.popoverDisappearnaceAnimator, popoverDisappearnaceAnimator.isRunning {
                            popoverDisappearnaceAnimator.stopAnimation(true)
                        }
                        self.popoverDisappearnaceAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7) {
                            self.notificationsPopover.alpha = 0
                            self.notificationsPopover.transform = CGAffineTransformMakeScale(0.5, 0.5)
                        }
//                        self.popoverDisappearnaceAnimator?.startAnimation()
                    }
                }
            }
        }
        
        let initialVC = self.viewControllers.first!
        self.addChild(initialVC)
        let childView = initialVC.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(childView, belowSubview: self.tabBar)
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            childView.topAnchor.constraint(equalTo: self.view.topAnchor),
            childView.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor)
        ])
        initialVC.didMove(toParent: self)
    }
    
    func transitionToPage(page: Page) {
        let pageIndex: Int
        switch page {
        case .home:
            pageIndex = 0
        case .explore:
            pageIndex = 1
        case .contentCreation:
            pageIndex = 2
        case .activity:
            pageIndex = 3
        case .profile:
            pageIndex = 4
        }
        self.tabBar.currentSelectionIndex = pageIndex
        self.transitionToTab(at: pageIndex)
    }
    
    private func transitionToTab(at index: Int) {
        
        if index == 2 {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let previousVC = self.viewControllers[self.currentVCIndex]
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        let newChildVC = self.viewControllers[index]
        self.addChild(newChildVC)
        let childView = newChildVC.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(childView, belowSubview: self.tabBar)
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            childView.topAnchor.constraint(equalTo: self.view.topAnchor),
            childView.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor)
        ])
        newChildVC.didMove(toParent: self)
        self.currentVCIndex = index
    }
    
    
    func tabBar(_: InstagramTabBar, didSelectTabAt selection: Int, previousSelection: Int) {
        guard selection != previousSelection else {
            self.viewControllers[selection].userRetappedTabButton()
            return
            
        }
        self.transitionToTab(at: selection)
    }
    
    func primaryPageViewController(_ viewController: PrimaryPageViewController, shouldAllowTransitionTo: PrimaryPageViewController.Page) -> Bool {
        return self.currentVCIndex == 0
    }
    
    enum Page {
        case home
        case explore
        case contentCreation
        case activity
        case profile
    }
}

private struct Configurations {
    
    static let tabBarHeight = 83.0
    
    static let dividerColor = UIColor(named: "TabBar/dividerColor")!
    
    static let dividerHeight = 1.0 / 3.0
    
    static let notificationsPopoverBottomSpacing = 4.0
}
