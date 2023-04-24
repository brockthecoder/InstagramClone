//
//  StoryHighlightReelView.swift
//  InstagramClone
//
//  Created by brock davis on 1/21/23.
//

import UIKit

class StoryHighlightReelView: UIView {
    
    var highlightReel: StoryHighlightReel? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        guard let highlightReel else { return }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw outline
        let outlineRect = CGRect(origin: .zero, size: .sqaure(size: self.bounds.width))
        context.addEllipse(in: outlineRect)
        let outlineClipRect = CGRect(x: (outlineRect.width - Configurations.outlineClipCircleDiameter) / 2, y: (outlineRect.height - Configurations.outlineClipCircleDiameter) / 2, width: Configurations.outlineClipCircleDiameter, height: Configurations.outlineClipCircleDiameter)
        context.addEllipse(in: outlineClipRect)
        context.clip(using: .evenOdd)
        Configurations.outlineColor.setFill()
        context.fill([outlineRect])
        
        // Draw cover image
        context.resetClip()
        let coverImageRect = CGRect(x: (outlineRect.width - Configurations.coverImageClipCircleDiameter) / 2, y: (outlineRect.height - Configurations.coverImageClipCircleDiameter) / 2, width: Configurations.coverImageClipCircleDiameter, height: Configurations.coverImageClipCircleDiameter)
        context.addEllipse(in: coverImageRect)
        context.clip()
        highlightReel.coverImage.draw(in: outlineClipRect)
        
        // Draw title
        context.resetClip()
        let titleText = NSAttributedString(string: highlightReel.title, attributes: Configurations.titleAttributes)
        let titleSize = titleText.size()
        let titleRect = CGRect(x: (outlineRect.width - titleSize.width) / 2, y: outlineRect.maxY + Configurations.titletopSacing, width: titleSize.width, height: titleSize.height)
        titleText.draw(in: titleRect)
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let outlineColor = UIColor(named: "ProfilePage/StoryHighlightReelView/outlineColor")!
    
    static let outlineClipCircleDiameter: CGFloat = 62
    
    static let coverImageClipCircleDiameter: CGFloat = 56
    
    static let titleAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/StoryHighlightReelView/titleColor")!,
        .font: UIFont.systemFont(ofSize: 12, weight: .regular)
    ]
    
    static let titletopSacing = screenWidth * 0.00848176420695504665
}
