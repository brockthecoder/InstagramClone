//
//  PrimaryPageViewController.swift
//  InstagramClone
//
//  Created by brock davis on 11/5/22.
//

import UIKit

class PrimaryPageViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, ContentCreationToTabBarTransitionAnimatorDelegate {
    
    static let shared = PrimaryPageViewController()
    
    private var navigationTransitionController: ContentCreationToTabBarTransitionAnimator?
    private let scrollView = UIScrollView()
    private let tabBarVC = InstagramTabBarController.shared
    private var tabBarView: UIView {
        self.tabBarVC.view!
    }
    private var tabBarKVOToken: NSKeyValueObservation!
    private let messagingVC = MessagingNavigationController()
    private var messagingView: UIView {
        self.messagingVC.view!
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabBarView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        self.messagingView.frame = CGRect(x: self.tabBarView.frame.maxX, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        self.scrollView.contentSize = CGSize(width: self.messagingView.frame.maxX, height: self.messagingView.frame.height)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // Set up the scroll view
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Set up the tab bar view
        self.addChild(self.tabBarVC)
        self.scrollView.addSubview(self.tabBarVC.view!)
        self.tabBarVC.didMove(toParent: self)
        self.tabBarKVOToken = self.tabBarVC.observe(\.currentVCIndex) { _, _ in
            self.scrollView.isScrollEnabled = self.tabBarVC.currentVCIndex == 0
        }
        
        // Set up the messaging view
        self.addChild(self.messagingVC)
        self.scrollView.addSubview(self.messagingVC.view!)
        self.messagingVC.didMove(toParent: self)
    }
    
    // ContentCreationToTabBarTransitionAnimatorDelegate conformance function
    // Prevent the user from popping the primary page VC when the tab bar view isn't on the home tab
    func transitionAnimatorShouldRecognize(animator: ContentCreationToTabBarTransitionAnimator) -> Bool {
        return self.tabBarVC.currentVCIndex == 0
    }
    
    
    func transitionTo(page: Page) {
        
        switch page {
        case .tabBar:
            self.scrollView.setContentOffset(.zero, animated: true)
        case .messaging:
            self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
        }
        
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return toVC is ContentCreationViewController ? self.navigationTransitionController : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (self.navigationTransitionController!.isInteracting && animationController === self.navigationTransitionController) ? self.navigationTransitionController : nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.delegate = self
            if self.navigationTransitionController == nil {
                self.navigationTransitionController = ContentCreationToTabBarTransitionAnimator(swipeDirection: .right, navigationController: navigationController, primaryPageVC: self)
                self.navigationTransitionController!.delegate = self
                self.tabBarView.addGestureRecognizer(self.navigationTransitionController!.gestureRecognizer)
            }
        }
    }

    enum Page {
        case tabBar
        case messaging
    }
}
