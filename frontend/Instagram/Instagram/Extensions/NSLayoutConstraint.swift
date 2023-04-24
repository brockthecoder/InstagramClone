//
//  NSLayoutConstraint.swift
//  Instagram
//
//  Created by brock davis on 3/6/23.
//

import UIKit

extension NSLayoutConstraint {
    
    func replaceWithNewMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(item: self.firstItem as Any, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem as Any, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
        self.isActive = false
        newConstraint.isActive = true
        return newConstraint
    }
}
