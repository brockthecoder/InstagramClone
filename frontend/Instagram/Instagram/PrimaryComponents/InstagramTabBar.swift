//
//  InstagramTabBar.swift
//  InstagramClone
//
//  Created by brock davis on 10/9/22.
//

import UIKit

class InstagramTabBar: UIView {
    
    private(set) var tabButtons: [InstagramTabButton] = []
    var delegate: InstagramTabBarDelegate?
    var currentSelectionIndex: Int = 0 {
        didSet {
            self.tabButtons[oldValue].isSelected = false
            self.tabButtons[self.currentSelectionIndex].isSelected = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    init(tabs: [(unselectedIcon: UIImage, selectedIcon: UIImage, hasNotifications: Bool)]) {
        super.init(frame: .zero)
        self.tabButtons = tabs.map { InstagramTabButton(selectedIcon: $0.selectedIcon, unselectedIcon: $0.unselectedIcon, hasNotification: $0.hasNotifications, targetClosure: self.tabButtonWasSelected(tabButton:))}
        self.backgroundColor = .black
        
        // Select the tab button at index 0
        self.tabButtons.first!.isSelected = true
        
        // Place the center tab button
        self.addSubview(self.tabButtons[2]) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.topAnchor),
                $0.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                $0.widthAnchor.constraint(equalToConstant: Configurations.tabButtonWidth)
            ])
        }
        
        // Place left-of-center tab buttons
        var prevTabButton = self.tabButtons[2]
        self.tabButtons.dropLast(3).reversed().forEach { tabButton in
            self.addSubview(tabButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.topAnchor.constraint(equalTo: self.topAnchor),
                    $0.trailingAnchor.constraint(equalTo: prevTabButton.leadingAnchor),
                    $0.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    $0.widthAnchor.constraint(equalToConstant: Configurations.tabButtonWidth)
                ])
            }
            prevTabButton = tabButton
        }
        
        // Place right-of-center tab buttons
        prevTabButton = self.tabButtons[2]
        self.tabButtons.dropFirst(3).forEach { tabButton in
            self.addSubview(tabButton) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.topAnchor.constraint(equalTo: self.topAnchor),
                    $0.leadingAnchor.constraint(equalTo: prevTabButton.trailingAnchor),
                    $0.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                    $0.widthAnchor.constraint(equalToConstant: Configurations.tabButtonWidth)
                ])
            }
            prevTabButton = tabButton
        }
    }
    
    private func tabButtonWasSelected(tabButton: InstagramTabButton) {
        let prevSelection = self.currentSelectionIndex
        self.currentSelectionIndex = self.tabButtons.firstIndex(of: tabButton)!
        self.delegate?.tabBar(self, didSelectTabAt: self.currentSelectionIndex, previousSelection: prevSelection)
    }
    
    
    func setNotificationStatus(forTabAtIndex ix: Int, hasNotification: Bool) {
        if ix >= 0 && ix < self.tabButtons.count {
            self.tabButtons[ix].hasNotification = hasNotification
        }
    }
    
    
}

protocol InstagramTabBarDelegate {
    func tabBar(_: InstagramTabBar, didSelectTabAt selection: Int, previousSelection: Int)
}

private struct Configurations {
    
    static let tabButtonWidth = 78.0
}
