//
//  NSRegularExpression.swift
//  InstagramClone
//
//  Created by brock davis on 11/8/22.
//

import Foundation

extension NSRegularExpression {
    
    static let hashtagMentionFinder = try! NSRegularExpression(pattern: "(\\s*#\\S++)|(\\s*@\\S++)")
}
