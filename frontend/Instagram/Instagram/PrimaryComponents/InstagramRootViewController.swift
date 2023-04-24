//
//  UpdatedInstagramRootViewController.swift
//  InstagramClone
//
//  Created by brock davis on 11/5/22.
//

import UIKit

class InstagramRootViewController: UINavigationController {
    
    private let primaryPageVC: PrimaryPageViewController
    private let contentCreationVC: ContentCreationViewController

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        self.primaryPageVC = PrimaryPageViewController.shared
        self.contentCreationVC = ContentCreationViewController.shared
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [contentCreationVC, primaryPageVC]
        self.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
}
