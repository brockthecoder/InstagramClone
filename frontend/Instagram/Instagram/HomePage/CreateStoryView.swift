//
//  CreateStoryView.swift
//  InstagramClone
//
//  Created by brock davis on 9/29/22.
//

import UIKit

class CreateStoryView: UIView {
    
    var profilePicture: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        let profilePictureRect = CGRect(x: self.bounds.midX - (Configurations.pfpCircleSize.width / 2), y: Configurations.pfpCircleTopSpacing,  width: Configurations.pfpCircleSize.width, height: Configurations.pfpCircleSize.height)
        context.addEllipse(in: profilePictureRect)
        context.clip()
        UIColor.gray.setFill()
        context.fill([profilePictureRect])
        if let profilePicture {
            profilePicture.draw(in: profilePictureRect)
        }
        context.resetClip()
        
        let plusIconRect = CGRect(x: profilePictureRect.minX + Configurations.plusIconOffset.width, y: profilePictureRect.minY + Configurations.plusIconOffset.height, width: Configurations.plusIconCircleSize.width, height: Configurations.plusIconCircleSize.height)
        UIColor.black.setStroke()
        context.setLineWidth(Configurations.plusIconCircleBorderWidth)
        Configurations.plusIconCircleFillColor.setFill()
        context.addEllipse(in: plusIconRect)
        context.drawPath(using: .fillStroke)
        
        
        let plusIconOrigin = CGPoint(x: plusIconRect.midX - (Configurations.plusIconSize.width / 2), y: plusIconRect.midY - (Configurations.plusIconSize.height / 2))
        Configurations.plusIcon.draw(at: plusIconOrigin)
        
    }
}

private struct Configurations {
    
    static let pfpCircleTopSpacing = 16.0 / 3.0
    static let pfpCircleSize = CGSize.sqaure(size: 64)
    
    static let plusIconCircleSize = CGSize.sqaure(size: 74.0 / 3.0)
    static let plusIconCircleBorderWidth = 10.0 / 3.0
    static let plusIconOffset = CGSize(width: 127.0 / 3.0, height: 127.0 / 3.0)
    
    static let plusIconSize = CGSize.sqaure(size: 10)
    static let plusIcon = UIImage(named: "Stories/Create/icon")!.resizedTo(size: plusIconSize).withTintColor(.white)
    
    static let plusIconCircleFillColor = UIColor(named: "Stories/Create/iconBackgroundColor")!
}

