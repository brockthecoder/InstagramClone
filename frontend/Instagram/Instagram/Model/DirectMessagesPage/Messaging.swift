//
//  Messaging.swift
//  InstagramClone
//
//  Created by brock davis on 10/19/22.
//

import UIKit

struct DirectMessage {
    
    let id: String
    
    let senderId: String
    
    let text: String
    
    let seen: Bool
    
    let timestamp: Date
    
}

struct Chat {
    
    let recipient: DirectMessageRecipient
    
    let lastMessage: DirectMessage
    
    let grouping: MessageGrouping
    
}

enum MessageGrouping {
    case primary
    case general
    case requests
    case hiddenRequests
}

struct DirectMessageRecipient {
    let id: String
    
    let profilePicture: UIImage
    
    let isVerified: Bool
    
    let followerCount: Int
    
    let displayName: String
    
    let story: Story?
    
    struct Story {
        
        let id: String
        
        var seen: Bool
    }
}
