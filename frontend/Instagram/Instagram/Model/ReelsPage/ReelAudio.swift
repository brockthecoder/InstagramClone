//
//  ReelAudio.swift
//  InstagramClone
//
//  Created by brock davis on 11/30/22.
//

import Foundation

struct ReelAudio {
    
    let title: String?
    
    let creator: FeedUser
    
    let isTrending: Bool
    
    let reelCount: Int
    
    let reels: [Reel] = []
}
