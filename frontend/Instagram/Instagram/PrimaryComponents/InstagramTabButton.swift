//
//  InstagramTabButton.swift
//  Instagram
//
//  Created by brock davis on 3/2/23.
//

import UIKit

class InstagramTabButton: UIView {

    private let pressRecognizer = UILongPressGestureRecognizer()
    private let targetClosure: (InstagramTabButton) -> ()
    private let selectedIcon: UIImage
    private let unselectedIcon: UIImage
    var isSelected: Bool = false {
        didSet {
            UIView.transition(with: self, duration: 0.05, options: [.transitionCrossDissolve, .curveEaseInOut, .allowAnimatedContent]) {
                self.setNeedsDisplay()
            }
        }
    }
    var isHighlighted: Bool = false {
        didSet {
            UIView.transition(with: self, duration: 0.05, options: [.transitionCrossDissolve, .curveEaseInOut, .allowAnimatedContent]) {
                self.setNeedsDisplay()
            }
        }
    }
    var hasNotification: Bool {
        didSet {
            UIView.transition(with: self, duration: 0.05, options: [.transitionCrossDissolve, .curveEaseInOut, .allowAnimatedContent]) {
                self.setNeedsDisplay()
            }
        }
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    init(selectedIcon: UIImage, unselectedIcon: UIImage, hasNotification: Bool = false, targetClosure: @escaping (InstagramTabButton) -> ()) {
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon
        self.hasNotification = hasNotification
        self.targetClosure = targetClosure
        super.init(frame: .zero)
        self.clearsContextBeforeDrawing = true
        self.backgroundColor = .black
        self.addGestureRecognizer(self.pressRecognizer)
        self.pressRecognizer.addTarget(self, action: #selector(self.handlePressEvent))
        self.pressRecognizer.allowableMovement = 50
        self.pressRecognizer.minimumPressDuration = 0
    }
    
    override func draw(_ rect: CGRect) {
        let icon = (self.isSelected || self.isHighlighted) ? selectedIcon : unselectedIcon
        
        let iconRect = CGRect(x: (self.bounds.width - icon.size.width) / 2, y: Configurations.iconCenterYSpacing - (icon.size.height / 2), width: icon.size.width, height: icon.size.height)
        
        icon.draw(in: iconRect)
        
        if self.hasNotification {
            let notificationRect = CGRect(x: iconRect.midX - (Configurations.notificationSize.width / 2), y: iconRect.midY + Configurations.notificationTopSpacingFromCenterOfIcon, width: Configurations.notificationSize.width, height: Configurations.notificationSize.height)
            Configurations.notificationColor.setFill()
            let context = UIGraphicsGetCurrentContext()!
            context.fillEllipse(in: notificationRect)
        }
    }
    
    @objc private func handlePressEvent() {
        switch self.pressRecognizer.state {
        case .began:
            self.isHighlighted = true
        case .cancelled:
            self.isHighlighted = false
        case .ended:
            self.isHighlighted = false
            if self.bounds.contains(self.pressRecognizer.location(in: self)) {
                self.isSelected = true
                self.targetClosure(self)
            }
        default:
            return
        }
    }
    
}

private struct Configurations {
    
    static let iconCenterYSpacing =  74.0 / 3.0
    
    static let notificationSize = CGSize.sqaure(size: 4)
    
    static let notificationTopSpacingFromCenterOfIcon = 50.0 / 3.0
    
    static let notificationColor = UIColor(named: "TabBar/notificationColor")!
}
