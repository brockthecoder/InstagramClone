//
//  ProfilePagePost.swift
//  InstagramClone
//
//  Created by brock davis on 1/17/23.
//

import UIKit


struct ProfilePagePost {
    
    let id: String
    
    let thumbnail: UIImage
    
    let isCarousel: Bool
    
    let isPinned: Bool
    
    let hasShoppingLinks: Bool
    
    let isReel: Bool

    init(id: String, thumbnail: UIImage, isCarousel: Bool, isPinned: Bool, hasShoppingLinks: Bool, isReel: Bool = false) {
        self.id = id
        self.thumbnail = thumbnail
        self.isCarousel = isCarousel
        self.isPinned = isPinned
        self.hasShoppingLinks = hasShoppingLinks
        self.isReel = isReel
    }
    
}

