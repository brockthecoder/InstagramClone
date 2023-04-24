//
//  Concurrency.swift
//  InstagramClone
//
//  Created by brock davis on 10/18/22.
//

import Foundation

extension DispatchQueue {
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        self.asyncAfter(deadline: when, execute: closure)
    }
}
