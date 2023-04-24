//
//  NSLayoutManager.swift
//  InstagramClone
//
//  Created by brock davis on 11/3/22.
//

import UIKit

extension NSLayoutManager {
    
    func numberOfLines() -> Int {
        
        var lineCount = 0
        
        self.enumerateLineFragments(forGlyphRange: NSMakeRange(0, self.numberOfGlyphs)) { _, _, _, _, _ in
            lineCount += 1
        }
        return lineCount
    }
    
    func glyphRangeForLineFragment(at fragmentIndex: Int) -> NSRange {
        var i = 0
        var glyphRange = NSMakeRange(0, 0)
        self.enumerateLineFragments(forGlyphRange: NSMakeRange(0, self.numberOfGlyphs)) { _, _, _, gRange, stop in
            guard i == fragmentIndex else {i += 1; return }
            stop.pointee = true
            glyphRange = gRange
        }
        return glyphRange
    }
}
