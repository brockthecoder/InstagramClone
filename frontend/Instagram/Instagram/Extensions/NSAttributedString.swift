//
//  NSAttributedString.swift
//  InstagramClone
//
//  Created by brock davis on 11/6/22.
//

import UIKit

extension NSParagraphStyle {
    
    static let centerAligned: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return paragraphStyle
    }()
}

extension NSAttributedString.Key {
    
    static let hashtag = NSAttributedString.Key("hashtag")
    
    static let mention = NSAttributedString.Key("mention")
}
