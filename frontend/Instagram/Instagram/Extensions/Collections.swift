//
//  Collections.swift
//  InstagramClone
//
//  Created by brock davis on 10/22/22.
//

import Foundation

extension Collection {
    
    subscript ( safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
