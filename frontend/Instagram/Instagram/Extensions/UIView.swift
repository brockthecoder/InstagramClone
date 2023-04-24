//
//  UIView.swift
//  InstagramClone
//
//  Created by brock davis on 1/22/23.
//

import UIKit

extension UIView {
    
    func addSubview(_ view: UIView, configurations: (UIView) -> ()) {
        self.addSubview(view)
        configurations(view)
    }
    
    func insertSubview(_ view: UIView, below: UIView, configurations: (UIView) -> ()) {
        self.insertSubview(view, belowSubview: below)
        configurations(view)
    }
    
    func insertSubview(_ view: UIView, aboveSubview: UIView, configurations: (UIView) -> ()) {
        self.insertSubview(view, aboveSubview: aboveSubview)
        configurations(view)
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
    
    var viewTree: [UIView] {
        
        var subviews = [UIView]()
        for view in self.subviews {
            subviews.append(view)
            subviews.append(contentsOf: view.viewTree)
        }
        return subviews
    }
}
