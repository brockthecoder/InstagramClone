//
//  ReelViewButton.swift
//  InstagramClone
//
//  Created by brock davis on 11/28/22.
//

import UIKit

class ReelPressEffectView: UIView {

    private let pressRecognizer = UILongPressGestureRecognizer()
    private var defaultTransform: CGAffineTransform?
    var animatedOpacity: CGFloat = 0.9
    var animatedScale: CGFloat = 0.8
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.addGestureRecognizer(self.pressRecognizer)
        self.pressRecognizer.cancelsTouchesInView = false
        self.pressRecognizer.minimumPressDuration = 0.1
        self.pressRecognizer.addTarget(self, action: #selector(self.userLongPressedView(recognizer:)))
    }
    
    @objc private func userLongPressedView(recognizer: UILongPressGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            self.defaultTransform = self.transform
            UIView.animate(withDuration: 0.1, delay: 0) {
                self.transform = CGAffineTransformScale(self.transform, self.animatedScale, self.animatedScale)
                self.alpha = self.animatedOpacity
            }
        case .changed:
            break
        default:
            UIView.animate(withDuration: 0.1, delay: 0) {
                self.transform = self.defaultTransform ?? CGAffineTransformIdentity
                self.alpha = 1
            }
        }
    }
}
