//
//  NotificationCountView.swift
//  InstagramClone
//
//  Created by brock davis on 11/1/22.
//

import UIKit

class NotificationsPopoverView: UIView {
    
    private let labels = [UILabel(), UILabel(), UILabel()]
    
    var notifications: ActivityNotifications? {
        didSet {
            for (ix, label) in labels.enumerated() {
                let (icon, count) = self.iconAndCount(for: ix)
                
                if count == 0 {
                    label.attributedText = nil
                    continue
                }
                let notificationCount = min(100, count)
                let iconAttachment = NSTextAttachment(image: icon)
                iconAttachment.bounds = CGRect(origin: CGPoint(x: 0, y: Configurations.iconYOffset), size: icon.size)
                let notificationText = NSMutableAttributedString(attachment: iconAttachment)
                notificationText.append(NSAttributedString(string: String(notificationCount), attributes: Configurations.notificationTextAttributes))
                label.attributedText = notificationText
            }
        }
    }
    
    private func iconAndCount(for ix: Int) -> (UIImage, Int) {
        switch ix {
        case 0:
            return (Configurations.commentIconWithSpacing, self.notifications?.unseenComments ?? 0)
        case 1:
            return (Configurations.likeIconWithSpacing, self.notifications?.unseenLikes ?? 0)
        default:
            return (Configurations.followerIconWithSpacing, self.notifications?.unseenFollows ?? 0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
        
        var prevLabel: UILabel?
        for label in labels {
            self.addSubview(label) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: prevLabel == nil ? self.leadingAnchor : prevLabel!.trailingAnchor),
                    $0.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(Configurations.bottomCurveSize.height / 2) - 1)
                ])
            }
            prevLabel = label
        }
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: Configurations.height),
            self.trailingAnchor.constraint(equalTo: prevLabel!.trailingAnchor, constant: Configurations.edgeInset)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - Configurations.bottomCurveSize.height)
        Configurations.fillColor.setFill()
        UIBezierPath(roundedRect: roundedRect, cornerRadius: Configurations.cornerRadius).fill()
        Configurations.bottomCurve.draw(at: CGPoint(x: roundedRect.midX - (Configurations.bottomCurveSize.width / 2), y: roundedRect.maxY))
        
    }
}

private struct Configurations {
    
    static let height = 44.0
    static let cornerRadius = 8.0
    static let fillColor = UIColor(named: "TabBar/NotificationPopover/fillColor")!
    static let bottomCurveSize = CGSize(width: 20, height: 8)
    static let bottomCurve = UIImage(named: "TabBar/NotificationPopover/bottomCurve")!.resizedTo(size: bottomCurveSize).withTintColor(fillColor)
    
    static let iconYOffset = -2.0
    static let iconFillColor = UIColor.white
    static let textLeadingSpacingFromIconCenter =  32.0 / 3.0
    static let labelLeadingSpacing = 35.0 / 3.0
    
    static let commentIconSize = CGSize.sqaure(size: 14)
    static let commentIcon = UIImage(named: "TabBar/NotificationPopover/commentIcon")!.withTintColor(iconFillColor).resizedTo(size: commentIconSize)
    static let commentIconWithSpacing = UIGraphicsImageRenderer(size: CGSize(width: labelLeadingSpacing + (commentIconSize.width / 2) + textLeadingSpacingFromIconCenter, height: commentIconSize.height)).image { _ in
        commentIcon.draw(at: CGPoint(x: labelLeadingSpacing, y: 0))
    }
    
    static let likeIconSize = CGSize(width: 44.0 / 3.0, height: 38.0 / 3.0)
    static let likeIcon = UIImage(named: "TabBar/NotificationPopover/likeIcon")!.withTintColor(iconFillColor).resizedTo(size: likeIconSize)
    static let likeIconWithSpacing = UIGraphicsImageRenderer(size: CGSize(width: labelLeadingSpacing + (likeIconSize.width / 2) + textLeadingSpacingFromIconCenter, height: likeIconSize.height)).image { _ in
        likeIcon.draw(at: CGPoint(x: labelLeadingSpacing, y: 0))
    }
    
    static let followerIconSize = CGSize.sqaure(size: 14)
    static let followerIcon = UIImage(named: "TabBar/NotificationPopover/followerIcon")!.withTintColor(iconFillColor).resizedTo(size: followerIconSize)
    static let followerIconWithSpacing = UIGraphicsImageRenderer(size: CGSize(width: labelLeadingSpacing + (followerIconSize.width / 2) + textLeadingSpacingFromIconCenter, height: followerIconSize.height)).image { _ in
        followerIcon.draw(at: CGPoint(x: labelLeadingSpacing, y: 0))
    }
    
    static let edgeInset = 35.0 / 3.0
    
    static let notificationTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 15, weight: .medium)
    ]
}
