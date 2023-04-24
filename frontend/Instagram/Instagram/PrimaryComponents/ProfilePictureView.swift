//
//  StoryView.swift
//  Instagram
//
//  Created by brock davis on 3/4/23.
//

import UIKit

class ProfilePictureView: UIView {
    
    private static let outlineGradient: CGGradient  = {
        let colors: [UIColor] = [.init(named: "Stories/GradientColors/0")!, .init(named: "Stories/GradientColors/1")!, .init(named: "Stories/GradientColors/2")!, .init(named: "Stories/GradientColors/3")!]
        var colorComponents = colors.compactMap { $0.cgColor.components}.flatMap{ $0 }
        return CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: &colorComponents, locations: [0.0, 0.33, 0.66, 1.0], count: 4)!
    }()
    
    private static let seenOutlineColor = UIColor(named: "Stories/seenOutlineColor")!
    
    private let outlineWidth: CGFloat
    
    var storyStatus: StoryStatus = .none {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var profilePicture: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw the outline if story
        if self.storyStatus != .none {
            let resolvedOutlineWidth = self.storyStatus == .seen ? self.outlineWidth / 2 : self.outlineWidth
            context.addEllipse(in: self.bounds)
            context.addEllipse(in: self.bounds.insetBy(dx: resolvedOutlineWidth, dy: resolvedOutlineWidth))
            context.clip(using: .evenOdd)
            if self.storyStatus == .seen {
                Self.seenOutlineColor.setFill()
                context.fillPath()
            } else {
                let gradientStart = self.bounds.origin.applying(CGAffineTransformMakeTranslation(0, self.bounds.height))
                let gradientEnd = self.bounds.origin.applying(CGAffineTransformMakeTranslation(self.bounds.width, 0))
                context.drawLinearGradient(Self.outlineGradient, start: gradientStart, end: gradientEnd, options: [])
            }
            context.resetClip()
            
        }
        
        // Draw the pfp
        let pfpEllipseRect = self.bounds.insetBy(dx: self.outlineWidth * 2, dy: self.outlineWidth * 2)
        context.addEllipse(in: pfpEllipseRect)
        context.clip()
        if let profilePicture {
            profilePicture.draw(in: pfpEllipseRect)
        } else {
            UIColor.black.setFill()
            context.fill([pfpEllipseRect])
        }
        
    }
    
    enum StoryStatus {
        case none
        case seen
        case unseen
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    init(outlineWidth: CGFloat) {
        self.outlineWidth = outlineWidth
        super.init(frame: .zero)
        self.isOpaque = false
    }
}
