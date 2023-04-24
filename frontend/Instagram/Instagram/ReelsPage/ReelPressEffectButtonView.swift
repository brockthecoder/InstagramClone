//
//  ReelPressEffectButton.swift
//  InstagramClone
//
//  Created by brock davis on 11/30/22.
//

import UIKit

class ReelPressEffectButtonView: UIView {

    let button = UIButton()
    let effectView = ReelPressEffectView()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        
        self.effectView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.effectView)
        NSLayoutConstraint.activate([
            self.effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.effectView.topAnchor.constraint(equalTo: self.topAnchor),
            self.effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.effectView.addSubview(self.button)
        NSLayoutConstraint.activate([
            self.button.leadingAnchor.constraint(equalTo: self.effectView.leadingAnchor),
            self.button.trailingAnchor.constraint(equalTo: self.effectView.trailingAnchor),
            self.button.topAnchor.constraint(equalTo: self.effectView.topAnchor),
            self.button.bottomAnchor.constraint(equalTo: self.effectView.bottomAnchor)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return self.button.intrinsicContentSize
    }

}
