//
//  ActivityNotifications.swift
//  Instagram
//
//  Created by brock davis on 3/2/23.
//

import Foundation

struct ActivityNotifications {
    
    var totalUnseen: Int {
        unseenLikes + unseenFollows + unseenComments
    }
    
    let unseenLikes: Int
    
    let unseenFollows: Int
    
    let unseenComments: Int
    
    static let zero = ActivityNotifications(unseenLikes: 0, unseenFollows: 0, unseenComments: 0)
}
