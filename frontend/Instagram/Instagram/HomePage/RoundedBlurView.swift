//
//  RoundedBlurView.swift
//  InstagramClone
//
//  Created by brock davis on 9/30/22.
//

import UIKit

class RoundedBlurView: UIVisualEffectView {
    
    private let maskLayer = CAShapeLayer()

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var cornerRadius: CGFloat {
        didSet {
            self.self.maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
        }
    }
    
    init(cornerRadius: CGFloat = 5, blurStyle: UIBlurEffect.Style = .regular) {
        self.cornerRadius = cornerRadius
        super.init(effect: UIBlurEffect(style: blurStyle))
        self.layer.mask = self.maskLayer
    }

}
