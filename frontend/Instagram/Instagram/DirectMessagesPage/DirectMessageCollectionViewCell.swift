//
//  DirectMessageCollectionViewCell.swift
//  InstagramClone
//
//  Created by brock davis on 10/19/22.
//

import UIKit

class DirectMessageCollectionViewCell: UICollectionViewCell {
    
    private static let unreadImageChatIcon = UIImage(named: "PictureMessageIcon")!.withTintColor(UIColor.white)
    private static let readImageChatIcon = UIImage(named: "PictureMessageIcon")!.withTintColor(UIColor.white.withAlphaComponent(0.6))
    private static let verifiedIcon = UIImage(named: "VerifiedIcon")!
    
    var chat: Chat! {
        didSet {
            if let chat {
                let recipient = chat.recipient
                self.pfpView.profilePicture = recipient.profilePicture
                if let recipientStory = recipient.story {
                    self.pfpView.storyStatus = recipientStory.seen ? .seen : .unseen
                } else {
                    pfpView.storyStatus = .none
                }
                let viewWidth = UIScreen.main.bounds.width
                let readFont = UIFont.systemFont(ofSize: viewWidth / 25, weight: .regular)
                let unreadFont = UIFont.systemFont(ofSize: viewWidth / 25, weight: .semibold)
                let unreadAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: unreadFont
                ]
                let readAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.white,
                    .font: readFont
                ]
                
                let userRealNameLabelText = NSMutableAttributedString(attributedString: ((chat.lastMessage.senderId != ActiveUser.loggedIn.first!.id) && !chat.lastMessage.seen) ? NSAttributedString(string: recipient.displayName, attributes: unreadAttributes) : NSAttributedString(string: recipient.displayName, attributes: readAttributes))
                
                if recipient.isVerified {
                    let attachment = NSTextAttachment(image: Self.verifiedIcon.resizedTo(size: CGSize.sqaure(size: (!chat.lastMessage.seen ? unreadFont : readFont).capHeight * 1.25)))
                    attachment.bounds = CGRect(x: 0, y: (((!chat.lastMessage.seen ? unreadFont : readFont).capHeight / 2) - attachment.image!.size.height / 1.9), width: attachment.image!.size.width, height: attachment.image!.size.height)
                    userRealNameLabelText.append(NSMutableAttributedString(string: " ", attributes: !chat.lastMessage.seen ? unreadAttributes : readAttributes))
                    userRealNameLabelText.append(NSAttributedString(attachment: attachment))
                }
                
                self.userRealNameLabel.attributedText = userRealNameLabelText
                self.messagePreviewLabel.attributedText = self.messagePreview(from: chat.lastMessage)
                self.createMediaMessageButton.setBackgroundImage(((chat.lastMessage.senderId != ActiveUser.loggedIn.first!.id) && !chat.lastMessage.seen) ? Self.unreadImageChatIcon : Self.readImageChatIcon, for: .normal)
                self.unreadMessagesCircle.isHidden = !(((chat.lastMessage.senderId != ActiveUser.loggedIn.first!.id) && !chat.lastMessage.seen))
            }
        }
    }
    
    private func messagePreview(from message: DirectMessage) -> NSAttributedString {
        let viewWidth = UIScreen.main.bounds.width
        let lowKeyStringAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: UIFont.systemFont(ofSize: viewWidth / 25, weight: .regular)
        ]
        let emphasisAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: viewWidth / 25, weight: .semibold)
        ]
        let activeUser = ActiveUser.loggedIn.first!
        let timeElapsed = Date().timeIntervalSince(message.timestamp)
        
        func formatPrefixString(string: String) -> String {
            return string.count <= 25 ? string : String(string[..<string.index(string.startIndex, offsetBy: 22)]).appending("...")
        }
        
        if message.senderId == activeUser.id {
            let previewPrefix = message.seen ? "Seen" : "Sent"
            if timeElapsed > 1209600 {
                return NSAttributedString(string: previewPrefix, attributes: lowKeyStringAttributes)
            }
            return NSAttributedString(string: previewPrefix + " " + self.timestampString(from: message.timestamp, shortFormat: false), attributes: lowKeyStringAttributes)
        } else {
            let previewPrefix = formatPrefixString(string: message.text)
            let previewText = NSMutableAttributedString()
            let messageUnread = !message.seen
            let attributedPreviewPrefix = NSAttributedString(string: previewPrefix, attributes: ((messageUnread) ? emphasisAttributes : lowKeyStringAttributes))
            let attributedPostfix = NSAttributedString(string:" · " + self.timestampString(from: message.timestamp, shortFormat: true), attributes: lowKeyStringAttributes)
            previewText.append(attributedPreviewPrefix)
            previewText.append(attributedPostfix)
            return previewText
        }
    }
    
    private func timestampString(from timestamp: Date, shortFormat: Bool = false) -> String {
        let timeElapsed = Date().timeIntervalSince(timestamp)
        if timeElapsed < 60 {
            return "now"
        } else if timeElapsed < 3600 {
            return "\(Int(timeElapsed/60))m\(shortFormat ? "" : " ago")"
        } else if timeElapsed < 86400 {
            return "\(Int(timeElapsed/3600))h\(shortFormat ? "" : " ago")"
        } else if timeElapsed < 604800 {
            return "\(Int(timeElapsed/86400))d\(shortFormat ? "" : " ago")"
        } else {
            return (timeElapsed < 1209600 && !shortFormat) ? "last week" : "\(Int(timeElapsed/604800))w\(shortFormat ? "" : " ago")"
        }
    }
        
    
    private let pfpView = ProfilePictureView(outlineWidth: 2)
    private let userRealNameLabel = UILabel()
    private let messagePreviewLabel = UILabel()
    private let unreadMessagesCircle = UIView()
    let createMediaMessageButton = UIButton()
    private static let selectedBackgroundColor = UIColor(named: "DMCellSelectedBackgroundColor")!
    private static let unreadMessageCircleColor = UIColor(named: "DMBlue")!
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        self.backgroundView = backgroundView
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Self.selectedBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView
        
        let viewWidth = UIScreen.main.bounds.width
        
        // Add the profile picture with support for story
        self.pfpView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.pfpView)
        NSLayoutConstraint.activate([
            self.pfpView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.pfpView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: viewWidth * 0.03),
            self.pfpView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.168),
            self.pfpView.heightAnchor.constraint(equalTo: self.pfpView.widthAnchor)
        ])
        
        // Add the User real name label
        self.userRealNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.userRealNameLabel)
        NSLayoutConstraint.activate([
            self.userRealNameLabel.leadingAnchor.constraint(equalTo: self.pfpView.trailingAnchor, constant: viewWidth * 0.0253),
            self.userRealNameLabel.centerYAnchor.constraint(equalTo: self.pfpView.centerYAnchor, constant: -viewWidth * 0.023)
        ])
        
        // Add the message preview label
        self.messagePreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.messagePreviewLabel)
        NSLayoutConstraint.activate([
            self.messagePreviewLabel.leadingAnchor.constraint(equalTo: self.userRealNameLabel.leadingAnchor),
            self.messagePreviewLabel.topAnchor.constraint(equalTo: self.userRealNameLabel.bottomAnchor, constant: viewWidth * 0.007)
        ])
        
        // Add the capture create button
        self.createMediaMessageButton.translatesAutoresizingMaskIntoConstraints = false
        self.createMediaMessageButton.setBackgroundImage(UIImage(named: "PictureMessageIcon")!, for: .normal)
        self.contentView.addSubview(self.createMediaMessageButton)
        NSLayoutConstraint.activate([
            self.createMediaMessageButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -viewWidth  * 0.04),
            self.createMediaMessageButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.createMediaMessageButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.0565),
            self.createMediaMessageButton.heightAnchor.constraint(equalTo: self.createMediaMessageButton.widthAnchor, multiplier: 0.95)
        ])
        
        // Add the unread messages view
        self.unreadMessagesCircle.translatesAutoresizingMaskIntoConstraints = false
        self.unreadMessagesCircle.layer.cornerRadius = viewWidth * 0.0085
        self.unreadMessagesCircle.backgroundColor = Self.unreadMessageCircleColor
        self.contentView.addSubview(self.unreadMessagesCircle)
        NSLayoutConstraint.activate([
            self.unreadMessagesCircle.trailingAnchor.constraint(equalTo: self.createMediaMessageButton.leadingAnchor, constant: -viewWidth * 0.039),
            self.unreadMessagesCircle.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.unreadMessagesCircle.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.0196),
            self.unreadMessagesCircle.heightAnchor.constraint(equalTo: self.unreadMessagesCircle.widthAnchor)
        ])
    }
}
