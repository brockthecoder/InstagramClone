//
//  ActivityViewController.swift
//  InstagramClone
//
//  Created by brock davis on 10/23/22.
//

import UIKit

class ActivityPageViewController: InstagramTabViewController {
    
    private let pageTitleLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(selectedTabIcon: Configurations.selectedTabIcon, unselectedTabIcon: Configurations.unselectedTabIcon, hasNotification: false)
        self.view.backgroundColor = .black
        
        // Setup the page title label
        self.pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.pageTitleLabel.attributedText = Configurations.pageTitlelabelText
        self.view.addSubview(self.pageTitleLabel)
        NSLayoutConstraint.activate([
            self.pageTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.pageTitleLabelLeadingSpacing),
            self.pageTitleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Configurations.pageTitleLabelTopSpacing)
        ])
        
        DispatchQueue.main.delay(3) {
            self.hasNotification = ActiveUser.loggedIn.first!.activityNotifications.totalUnseen > 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hasNotification = false
    }
}

private struct Configurations {
    
    static let tabIconSize = CGSize(width: 70.0 / 3.0, height: 61.0 / 3.0)
    static let tabIconFillColor = UIColor(named: "ActivityPage/tabIconFillColor")!
    static let unselectedTabIcon = UIImage(named: "ActivityPage/tabIconUnselected")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    static let selectedTabIcon = UIImage(named: "ActivityPage/tabIconSelected")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    
    
    static let screenWidth = UIScreen.main.bounds.width
    
    // Page Title Configurations
    static let pageTitleLabelLeadingSpacing = screenWidth * 0.05
    static let pageTitleLabelTopSpacing = screenWidth * 0.175
    static let pageTitlelabelText = NSAttributedString(string: "Notifications", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.063, weight: .semibold)
    ])
}
