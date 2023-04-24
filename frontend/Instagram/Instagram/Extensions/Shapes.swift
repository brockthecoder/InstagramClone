//
//  Shapes.swift
//  InstagramClone
//
//  Created by brock davis on 9/28/22.
//

import Foundation

extension CGSize {
    
    static func sqaure(size: CGFloat) -> CGSize {
        CGSize(width: size, height: size)
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
}
