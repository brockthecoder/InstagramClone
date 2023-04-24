//
//  FeedPostLiker.swift
//  Instagram
//
//  Created by brock davis on 3/5/23.
//

import UIKit

struct FeedUser {
    let id: String
    
    let username: String
    
    let isVerified: Bool
    
    let profilePictureURL: URL
    
    let hasStory: Bool
    
    let activeUserFollows: Bool
    
    var profilePictureImage: UIImage {
        let data = try! Data(contentsOf: self.profilePictureURL)
        return UIImage(data: data)!
    }
}
