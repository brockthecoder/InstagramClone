//
//  File.swift
//  InstagramClone
//
//  Created by brock davis on 11/4/22.
//

import UIKit

func findFontMultiplier(font: UIFont, desiredCapHeight: CGFloat, maxDeviaton: CGFloat = 0.01) -> CGFloat {
    let screenWidth = UIScreen.main.bounds.width
    
    for multiplier in stride(from: 0.0, to: 1.0, by: 0.00001) {
        let font = font.withSize(screenWidth * multiplier)
        if abs(font.capHeight - desiredCapHeight) <= maxDeviaton {
            return multiplier
        }
    }
    
    return .greatestFiniteMagnitude
}
