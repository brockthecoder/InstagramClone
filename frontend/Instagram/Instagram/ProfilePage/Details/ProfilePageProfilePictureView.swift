//
//  ProfilePictureView.swift
//  InstagramClone
//
//  Created by brock davis on 1/19/23.
//

import UIKit

class ProfilePageProfilePictureView: UIView {
    
    var mode: Mode = .noStory {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var profilePicture: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    enum Mode {
        case noStory
        case unseenStory
        case seenStory
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
        self.contentMode = .redraw
    }
    
    override var intrinsicContentSize: CGSize {
        return Configurations.outerCircleSize
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let profilePicture else { return }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Only draw outline when user has story
        if self.mode != .noStory {
            // Draw the circular outline
            let outerEllipseRect = CGRect(origin: .zero, size: Configurations.outerCircleSize)
            context.addEllipse(in: outerEllipseRect)
            let clipSize = self.mode == .seenStory ? Configurations.solidOutlineClipCircleSize : Configurations.gradientOutlineClipCircleSize
            let clipEllipseRect = CGRect(x: (outerEllipseRect.width - clipSize.width) / 2, y: (outerEllipseRect.height - clipSize.height) / 2, width: clipSize.width, height: clipSize.height)
            context.addEllipse(in: clipEllipseRect)
            context.clip(using: .evenOdd)
            Configurations.solidOutlineColor.setFill()
            context.fillEllipse(in: outerEllipseRect)
            
            // Draw gradient for unseen story
            if self.mode == .unseenStory {
                var colorComponents = Configurations.gradientColors.compactMap { $0.components}.flatMap { $0 }
                var locations: [CGFloat] = [0, 0.33, 0.66, 1]
                let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: &colorComponents, locations: &locations, count: 4)!
                let start = CGPoint(x: outerEllipseRect.width * 0.145, y: outerEllipseRect.maxY * 0.855)
                let end = CGPoint(x: outerEllipseRect.width * 0.855, y: outerEllipseRect.height * 0.145)
                context.drawLinearGradient(gradient, start: start, end: end, options: [])
            }
            context.resetClip()
        }
        
        func rectAroundPoint(point: CGPoint) -> CGRect {
            return CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
        }
        
        // Draw profile picture
        let clippedPictureSize = Configurations.profilePictureClipCircleSize
        let pictureClipRect = CGRect(x: (self.bounds.width - clippedPictureSize.width) / 2, y: (self.bounds.height - clippedPictureSize.height) / 2, width: clippedPictureSize.width, height: clippedPictureSize.height)
        context.addEllipse(in: pictureClipRect)
        context.clip()
        profilePicture.draw(in: pictureClipRect)
        context.resetClip()
        
        // Draw add story icon when user has no story
        if self.mode == .noStory {
            // Fill the outer ellipse
            let addStoryOuterRectOrigin = CGPoint(x: pictureClipRect.maxX - Configurations.addStoryOuterCircleSize.width, y: pictureClipRect.maxY - Configurations.addStoryOuterCircleSize.height)
            let addStoryOuterRect = CGRect(origin: addStoryOuterRectOrigin, size: Configurations.addStoryOuterCircleSize)
            Configurations.addStoryOuterCircleColor.setFill()
            context.fillEllipse(in: addStoryOuterRect)
            // Fill the inner ellipse
            let addStoryInnerRectOrigin = CGPoint(x: addStoryOuterRect.minX + ((addStoryOuterRect.width - Configurations.addStoryInnerCircleSize.width) / 2), y: addStoryOuterRect.minY + ((addStoryOuterRect.height - Configurations.addStoryInnerCircleSize.height) / 2))
            let addStoryInnerRect = CGRect(origin: addStoryInnerRectOrigin, size: Configurations.addStoryInnerCircleSize)
            Configurations.addStoryInnerCircleColor.setFill()
            context.fillEllipse(in: addStoryInnerRect)
            // Draw the add icon
            let plusIconOrigin = CGPoint(x: addStoryInnerRect.minX + ((addStoryInnerRect.width - Configurations.plusIconSize.width) / 2), y: (addStoryInnerRect.minY + (addStoryInnerRect.height - Configurations.plusIconSize.height) / 2))
            let plusIconRect = CGRect(origin: plusIconOrigin, size: Configurations.plusIconSize)
            Configurations.plusIcon.draw(in: plusIconRect)
        }
    }

}
                                                                                                                                                                                                                                                                                          
private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let outerCircleSize = CGSize.sqaure(size: screenWidth * 0.2495)
    
    static let gradientOutlineClipCircleSize = CGSize.sqaure(size: screenWidth * 0.2335)
    
    static let gradientColors = [UIColor(named: "ProfilePage/Details/ProfilePictureButton/StoryIndicator/gradient0")!.cgColor,
                                 UIColor(named: "ProfilePage/Details/ProfilePictureButton/StoryIndicator/gradient1")!.cgColor,
                                 UIColor(named: "ProfilePage/Details/ProfilePictureButton/StoryIndicator/gradient2")!.cgColor,
                                 UIColor(named: "ProfilePage/Details/ProfilePictureButton/StoryIndicator/gradient3")!.cgColor
    ]
    
    static let solidOutlineClipCircleSize = CGSize.sqaure(size: screenWidth * 0.239795)
    
    static let solidOutlineColor = UIColor(named: "ProfilePage/Details/ProfilePictureButton/StoryIndicator/viewedColor")!
    
    static let profilePictureClipCircleSize = CGSize.sqaure(size: screenWidth * 0.2187)
    
    static let addStoryOuterCircleSize = CGSize.sqaure(size: screenWidth * 0.059778911)
    
    static let addStoryInnerCircleSize = CGSize.sqaure(size: screenWidth * 0.05102)
    
    static let addStoryOuterCircleColor = UIColor(named: "ProfilePage/Details/ProfilePictureButton/CreateStoryIcon/outerCircleFillColor")!
    
    static let addStoryInnerCircleColor = UIColor(named: "ProfilePage/Details/ProfilePictureButton/CreateStoryIcon/innerCircleFillColor")!
    
    static let plusIcon = UIImage(named: "ProfilePage/Details/ProfilePictureButton/CreateStoryIcon/plusIcon")!.withTintColor(UIColor(named: "ProfilePage/Details/ProfilePictureButton/CreateStoryIcon/plusIconFillColor")!)
    
    static let plusIconSize = CGSize.sqaure(size: screenWidth * 0.02534013)
}
