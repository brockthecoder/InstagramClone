//
//  UIImageExtensions.swift
//  InstagramClone
//
//  Created by brock davis on 9/28/22.
//

import UIKit

extension UIImage {
    func resizedTo(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: .init(origin: .zero, size: size))
        }
    }
    
    func drawAspectScale(in rect: CGRect) {
        let aspect = self.size.width / self.size.height
        
        if rect.width / aspect <= rect.height {
            self.draw(in: CGRect(x: rect.origin.x, y: rect.origin.y - (((rect.width / aspect) - rect.height) / 2), width: rect.width, height: rect.width / aspect))
        } else {
            let newSize = CGSize(width: rect.height * aspect, height: rect.height)
            self.resizedTo(size: CGSize(width: rect.height * aspect, height: rect.height)).draw(at: CGPoint(x: rect.midX - (newSize.width / 2), y: rect.midY - (newSize.height / 2)))
        }
    }
}
