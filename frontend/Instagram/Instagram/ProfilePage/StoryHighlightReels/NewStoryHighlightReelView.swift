//
//  NewStoryHighlightReelView.swift
//  InstagramClone
//
//  Created by brock davis on 1/21/23.
//

import UIKit

class NewStoryHighlightReelView: UIView {

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw outline
        let outlineRect = CGRect(origin: .zero, size: .sqaure(size: self.bounds.width))
        context.addEllipse(in: outlineRect)
        let outlineClipRect = CGRect(x: (outlineRect.width - Configurations.outlineClipCircleDiameter) / 2, y: (outlineRect.height - Configurations.outlineClipCircleDiameter) / 2, width: Configurations.outlineClipCircleDiameter, height: Configurations.outlineClipCircleDiameter)
        context.addEllipse(in: outlineClipRect)
        context.clip(using: .evenOdd)
        Configurations.outlineColor.setFill()
        context.fill([outlineRect])
        
        // Draw new icon
        context.resetClip()
        let iconRect = CGRect(x: (outlineRect.width - Configurations.newIconSize.width) / 2, y: (outlineRect.height - Configurations.newIconSize.height) / 2, width: Configurations.newIconSize.width, height: Configurations.newIconSize.height)
        Configurations.newIcon.draw(in: iconRect)
        
        // Draw title
        let titleText = NSAttributedString(string: "New", attributes: Configurations.titleAttributes)
        let titleSize = titleText.size()
        let titleRect = CGRect(x: (outlineRect.width - titleSize.width) / 2, y: outlineRect.maxY + Configurations.titletopSacing, width: titleSize.width, height: titleSize.height)
        titleText.draw(in: titleRect)
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let outlineColor = UIColor(named: "ProfilePage/StoryHighlightReelView/newHighlightOutlineColor")!
    
    static let outlineClipCircleDiameter: CGFloat = 62
    
    static let newIcon = UIImage(named: "ProfilePage/StoryHighlightReelView/newHighlightIcon")!.withTintColor(UIColor(named: "ProfilePage/StoryHighlightReelView/newHighlightIconFillColor")!)
    
    static let newIconSize = CGSize.sqaure(size: 20)
    
    static let titleAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/StoryHighlightReelView/titleColor")!,
        .font: UIFont.systemFont(ofSize: 12, weight: .regular)
    ]
    
    static let titletopSacing = screenWidth * 0.00848176420695504665
}
