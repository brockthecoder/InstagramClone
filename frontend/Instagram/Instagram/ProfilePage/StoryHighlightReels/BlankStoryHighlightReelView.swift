//
//  BlankStoryHighlightReelView.swift
//  InstagramClone
//
//  Created by brock davis on 3/2/23.
//

import UIKit

class BlankStoryHighlightReelView: UIView {
    
    private static let fillColor = UIColor(named: "ProfilePage/StoryHighlightReelView/NoHighlightReels/blankStoryHighlightReelFillColor")!
    
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let ellipseRect = CGRect(origin: .zero, size: .sqaure(size: self.bounds.width))
        context.setFillColor(Self.fillColor.cgColor)
        context.fillEllipse(in: ellipseRect)
    }

}
