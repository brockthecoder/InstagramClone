//
//  ContentCreationViewController.swift
//  InstagramClone
//
//  Created by brock davis on 10/16/22.
//

import UIKit
import AVFoundation

class ContentCreationViewController: InstagramTabViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    static let shared = ContentCreationViewController()
    
    private var navigationTransitionController: ContentCreationToTabBarTransitionAnimator?
    private let scrollView = UIScrollView()
    private var cameraCaptureVC: CameraCaptureViewController!
    private var cameraCaptureView: UIView {
        self.cameraCaptureVC.view!
    }
    private let photoLibraryVC = PhotoLibraryAssetSelectionViewController(useType: .story)
    private var photoLibraryView: UIView {
        self.photoLibraryVC.view!
    }
    var contentOffsetObservationToken: NSKeyValueObservation?
    var rootViewControllerPageObservationToken: NSKeyValueObservation?
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let recognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        if recognizer.view == self.view.superview {
            return self.scrollView.contentOffset.y == 0
        }
        return true
    }
    
    init() {
        super.init(selectedTabIcon: Configurations.selectedTabIcon, unselectedTabIcon: Configurations.unselectedTabIcon, hasNotification: false)
        self.cameraCaptureVC = CameraCaptureViewController(cameraPosition: .front, photoLibraryVC: self.photoLibraryVC)
        
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.bounces = false
        self.scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        self.contentOffsetObservationToken = self.scrollView.observe(\UIScrollView.contentOffset, options: [.new]) { scrollView, change in
            
            let contentOffset = self.scrollView.contentOffset
            self.cameraCaptureView.alpha = 1 - (contentOffset.y / self.view.bounds.height)
                
            // Need to remove a child VC view if the new content offset represents the next page
            if contentOffset == .zero || contentOffset.y == self.view.bounds.height {
                // Remove the child VC not in frame
                let childToRemove = scrollView.contentOffset == .zero ? self.photoLibraryVC : self.cameraCaptureVC!
                childToRemove.willMove(toParent: nil)
                childToRemove.view.removeFromSuperview()
                childToRemove.removeFromParent()
            } else if self.children.count == 1 {
                // Need to add a view controller if the user is scrolling and the other child view isn't in frame
                let childToAdd = (scrollView.contentOffset.y < self.view.bounds.height * 0.9) ? self.photoLibraryVC : self.cameraCaptureVC!
                self.addChild(childToAdd)
                self.scrollView.addSubview(childToAdd.view)
                childToAdd.didMove(toParent: self)
            }
        }
        
        self.view.backgroundColor = .black
        
        self.addChild(self.cameraCaptureVC)
        self.scrollView.addSubview(self.cameraCaptureView)
        self.cameraCaptureVC.didMove(toParent: self)
        
        self.addChild(self.photoLibraryVC)
        self.scrollView.addSubview(self.photoLibraryView)
        self.photoLibraryVC.didMove(toParent: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navigationController = self.navigationController {
            navigationController.delegate = self
            if self.navigationTransitionController == nil {
                self.navigationTransitionController = ContentCreationToTabBarTransitionAnimator(swipeDirection: .left, navigationController: navigationController, primaryPageVC: PrimaryPageViewController.shared)
                self.cameraCaptureView.addGestureRecognizer(self.navigationTransitionController!.gestureRecognizer)
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        InstagramTabBarController.shared.transitionToPage(page: .home)
        return self.navigationTransitionController
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.navigationTransitionController!.isInteracting ? self.navigationTransitionController : nil
    }
    
    func scrollToChild(child: ContentCreationViewControllerChildType) {
        switch child {
        case .cameraCapture:
            self.scrollView.setContentOffset(.zero, animated: true)
        case .photoLibrarySelect:
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height), animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.scrollView.frame = self.view.bounds
        self.cameraCaptureView.frame = CGRect(origin: .zero, size: self.view.bounds.size)
        self.photoLibraryView.frame = CGRect(x: 0, y: cameraCaptureView.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height)
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: (self.cameraCaptureView.bounds.height + self.photoLibraryView.bounds.height))
    }
}

enum ContentCreationViewControllerChildType {
    case cameraCapture
    case photoLibrarySelect
}

private struct Configurations {
    
    static let tabIconFillColor = UIColor(named: "ContentCreationPage/TabBar/iconFillColor")!
    static let tabIconSize = CGSize.sqaure(size: 22)
    static let selectedTabIcon = UIImage(named: "ContentCreationPage/TabBar/selectedIcon")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    static let unselectedTabIcon = UIImage(named: "ContentCreationPage/TabBar/unselectedIcon")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
}
