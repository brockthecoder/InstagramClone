//
//  FeedReelPostAudio.swift
//  Instagram
//
//  Created by brock davis on 3/5/23.
//

import Foundation

struct PostAudio {
    
    let artistDisplayName: String
    
    let audioTitle: String
    
    let explicit: Bool
    
    init(artistDisplayName: String, audioTitle: String = "Original audio", explicit: Bool = false) {
        self.artistDisplayName = artistDisplayName
        self.audioTitle = audioTitle
        self.explicit = explicit
    }
}
