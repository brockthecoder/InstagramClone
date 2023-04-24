//
//  ExplorePageViewController.swift
//  InstagramClone
//
//  Created by brock davis on 9/28/22.
//

import UIKit

class ExplorePageViewController: InstagramTabViewController {
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(selectedTabIcon: Configuratiions.selectedTabIcon, unselectedTabIcon: Configuratiions.unselectedTabIcon, hasNotification: false)
    }
}

private struct Configuratiions {
    static let tabIconFillColor = UIColor(named: "ExplorePage/tabIconFillColor")!
    static let tabIconSize = CGSize.sqaure(size: 22)
    static let selectedTabIcon = UIImage(named: "ExplorePage/selectedTabIcon")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    static let unselectedTabIcon = UIImage(named: "ExplorePage/unselectedTabIcon")!.withTintColor(tabIconFillColor).resizedTo(size: tabIconSize)
    
}
