//
//  IgButtonMenu.swift
//  InstagramClone
//
//  Created by brock davis on 9/30/22.
//

import UIKit

class IgButtonMenuView: UIView {

    private let backgroundView = RoundedBlurView(blurStyle: .systemMaterial)
    private let contentView = IgButtonMenuContentView()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
        
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backgroundView)
        NSLayoutConstraint.activate([
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentView)
        NSLayoutConstraint.activate([
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView.cornerRadius = self.bounds.width / 12
    }
  
}

private class IgButtonMenuContentView: UIView {
    
    private let followingIcon = UIImage(named: "FollowingMenuIcon")!
    private let favoritesIcon = UIImage(named: "FavoritesMenuIcon")!.withTintColor(.white)
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        
        let actionRectHeight = (self.bounds.height / 2) - 1
        
        let followingActionRect = CGRect(x: 0, y: 0, width: self.bounds.width, height: actionRectHeight)
        let dividerRect = CGRect(x: 0, y: followingActionRect.maxY, width: self.bounds.width, height: 0.3)
        let favoritesActionRect = CGRect(x: 0, y: dividerRect.origin.y + 1, width: self.bounds.width, height: actionRectHeight)
        
        
        let actionFont = UIFont.systemFont(ofSize: self.bounds.height / 5, weight: .regular)
        let followingTextRect = CGRect(x: followingActionRect.maxX * 0.105, y: followingActionRect.midY - (actionFont.lineHeight / 2), width: followingActionRect.width * 0.65, height: actionFont.lineHeight)
        let favoritesTextRect = CGRect(x: favoritesActionRect.maxX * 0.105, y: favoritesActionRect.midY - (actionFont.lineHeight / 2), width: favoritesActionRect.width * 0.65, height: actionFont.lineHeight)
        
        
        
        let iconHeight = actionRectHeight / 2
        
        let followingIconRect = CGRect(x: followingTextRect.origin.x + followingTextRect.width, y: followingActionRect.origin.y + (iconHeight / 2), width: iconHeight, height: iconHeight)
        let favoritesIconRect = CGRect(x: favoritesTextRect.origin.x + favoritesTextRect.width, y: favoritesActionRect.origin.y + (iconHeight / 2), width: iconHeight, height: iconHeight)
        
        
        // Draw the action text
        ("Following" as NSString).draw(in: followingTextRect, withAttributes: [
            .foregroundColor: UIColor.white,
            .font: actionFont
        ])
        ("Favorites" as NSString).draw(in: favoritesTextRect, withAttributes: [
            .foregroundColor: UIColor.white,
            .font: actionFont
        ])
        
        // Draw the action icons
        self.followingIcon.draw(in: followingIconRect)
        self.favoritesIcon.draw(in: favoritesIconRect)
        
        // Draw the divider
        let dividerFillColor = #colorLiteral(red: 0.498, green: 0.482, blue: 0.486, alpha: 1.0).cgColor
        context.setFillColor(dividerFillColor)
        context.addRect(dividerRect)
        context.fillPath()
    }
}
