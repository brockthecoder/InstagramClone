//
//  UIColor.swift
//  InstagramClone
//
//  Created by brock davis on 11/28/22.
//

import UIKit

extension UIColor {
    
    static var random: UIColor {
        UIColor(red: CGFloat.random(in: 0.0...1.0), green: CGFloat.random(in: 0.0...1.0), blue: CGFloat.random(in: 0.0...1.0), alpha: 1)
    }
}
