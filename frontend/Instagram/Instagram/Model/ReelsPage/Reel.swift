//
//  Reel.swift
//  InstagramClone
//
//  Created by brock davis on 11/9/22.
//

import UIKit

struct Reel {
    
    let id: String
    
    let previewImage: UIImage?
    
    let mediaURL: URL
    
    let likeCount: Int
    
    let commentCount: Int
    
    let shareCount: Int
    
    let creator: FeedUser
    
    let caption: String?
    
    let audio: ReelAudio
    
    let taggedUsers: [FeedUser] = []
    
    let playCount: Int
}
