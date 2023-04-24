//
//  InstagramTabViewController.swift
//  InstagramClone
//
//  Created by brock davis on 11/2/22.
//

import UIKit

class InstagramTabViewController: UIViewController {

    var selectedTabIcon: UIImage
    
    var unselectedTabIcon: UIImage
    
    @objc dynamic var hasNotification: Bool
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func userRetappedTabButton() {
        
    }
    
    init(selectedTabIcon: UIImage, unselectedTabIcon: UIImage, hasNotification: Bool) {
        self.selectedTabIcon = selectedTabIcon
        self.unselectedTabIcon = unselectedTabIcon
        self.hasNotification = hasNotification
        super.init(nibName: nil, bundle: nil)
    }

}
