//
//  MessengerNotifications.swift
//  Instagram
//
//  Created by brock davis on 3/3/23.
//

import Foundation

struct MessengerNotifications {
    
    var totalNotifications: Int {
        return unseenRequests + unseenPrimaryMessages + unseenGeneralMessages
    }
    
    var totalMessages: Int {
        return self.unseenGeneralMessages + self.unseenPrimaryMessages
    }
    
    let unseenRequests: Int
    
    let unseenPrimaryMessages: Int
    
    let unseenGeneralMessages: Int
    
    static let zero = MessengerNotifications(unseenRequests: 0, unseenPrimaryMessages: 0, unseenGeneralMessages: 0)
}
