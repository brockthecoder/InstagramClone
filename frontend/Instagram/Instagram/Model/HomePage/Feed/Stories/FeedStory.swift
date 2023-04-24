//
//  Story.swift
//  InstagramClone
//
//  Created by brock davis on 10/19/22.
//

import UIKit

struct FeedStory {
    let id: String
    
    let profilePicture: UIImage
    
    let username: String
    
    init(id: String, profilePictureURL: URL, username: String) {
        self.id = id
        self.username = username
        let imageData = try! Data(contentsOf: profilePictureURL)
        self.profilePicture = UIImage(data: imageData)!
    }
}
