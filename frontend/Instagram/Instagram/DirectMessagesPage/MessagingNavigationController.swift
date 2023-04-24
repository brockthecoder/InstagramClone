//
//  MessagingNavigationController.swift
//  InstagramClone
//
//  Created by brock davis on 10/19/22.
//

import UIKit

class MessagingNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    private let messagingViewController = MessagingViewController()
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            return self.topViewController != self.messagingViewController
        } else if gestureRecognizer.view == self.view.superview {
            return self.topViewController == self.messagingViewController
        } else {
            return true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(rootViewController: self.messagingViewController)
        self.setNavigationBarHidden(true, animated: false)
        self.interactivePopGestureRecognizer?.delegate = self
    }

}
