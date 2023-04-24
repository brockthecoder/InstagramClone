//
//  DirectMessageRequestCollectionViewCell.swift
//  InstagramClone
//
//  Created by brock davis on 11/4/22.
//

import UIKit

class DirectMessageRequestCollectionViewCell: UICollectionViewCell {
    
    var chatRequest: Chat! {
        didSet {
            if let chatRequest {
                
                let requester = chatRequest.recipient
                
                // Update the story view
                self.pfpView.profilePicture = requester.profilePicture
                if let requesterStory = requester.story {
                    self.pfpView.storyStatus = requesterStory.seen ? .seen : .unseen
                } else {
                    self.pfpView.storyStatus = .none
                }
                
                // Generate the message preview text
                let requestUnread = !chatRequest.lastMessage.seen
                self.unreadRequestDot.isHidden = !requestUnread
                self.layoutIfNeeded()
                let maxPreviewWidth = self.unreadRequestDot.frame.minX - 5 - self.messagePreviewLabel.frame.minX
                self.messagePreviewLabel.attributedText = self.messagePreview(from: chatRequest.lastMessage, maxWidth: maxPreviewWidth)
                
                // Generate the user real name text
                let attributesToApply = requestUnread ? Configurations.userRealNameLabelUnreadTextAttributes : Configurations.userRealNameLabelReadTextAttributes
                let realNameLabelText = NSMutableAttributedString(attributedString: NSAttributedString(string: chatRequest.recipient.displayName, attributes: attributesToApply))

                if chatRequest.recipient.isVerified {
                    let attachment = NSTextAttachment(image: requestUnread ? Configurations.unreadRequestVerifiedIcon : Configurations.readRequestVerifiedIcon)
                    let fontCapHeight = (attributesToApply[.font] as! UIFont).capHeight
                    attachment.bounds = CGRect(x: 0, y: fontCapHeight - (attachment.image!.size.height / 1.9), width: attachment.image!.size.width, height: attachment.image!.size.height)
                    realNameLabelText.append(NSMutableAttributedString(string: " ", attributes: attributesToApply))
                    realNameLabelText.append(NSAttributedString(attachment: attachment))
                }
                self.userRealNameLabel.attributedText = realNameLabelText
                
                // Generate the follower count text
                self.followerCountLabel.attributedText = self.followerCountString(forRequester: requester)
            }
        }
    }
    
    private func messagePreview(from message: DirectMessage, maxWidth: CGFloat) -> NSAttributedString {
    
        let previewTimestamp = NSAttributedString(string: " · " + self.timestampString(from: message.timestamp, shortFormat: true), attributes: Configurations.messagePreviewTimestampTextAttributes)
        let previewTimestampSize = previewTimestamp.size()
        
        let previewTextAttributes = message.seen ? Configurations.messagePreviewUnreadTextAttributes : Configurations.messagePreviewReadTextAttributes
        let previewPrefix = message.text
        let trimmedPrefix = NSMutableAttributedString(string: previewPrefix, attributes: previewTextAttributes)
        let startLength = trimmedPrefix.length
        while (trimmedPrefix.size().width > (maxWidth - previewTimestampSize.width)) {
            trimmedPrefix.deleteCharacters(in: NSMakeRange(trimmedPrefix.length - 1, 1))
        }
        if trimmedPrefix.length < startLength {
            trimmedPrefix.replaceCharacters(in: NSMakeRange(trimmedPrefix.length - 3, 3), with: "...")
        }
        
        trimmedPrefix.append(previewTimestamp)
        return trimmedPrefix
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
    
    private func followerCountString(forRequester requester: DirectMessageRecipient) -> NSAttributedString {
        let followerCount = requester.followerCount
        
        var followerCountString: String
        if followerCount < 1 {
            followerCountString = "0 followers"
        } else if followerCount < 10000 {
            followerCountString = self.followerCountFormatter.string(from: NSNumber(integerLiteral: followerCount))!  + " followers"
        } else if followerCount < 1000000 {
            let wholePart = followerCount / 1000
            let fractionalPart = (followerCount - wholePart) / 100
            followerCountString = fractionalPart > 0 ? "\(wholePart).\(fractionalPart)K followers" : "\(wholePart)K followers"
        } else {
            followerCountString = "\(followerCount / 1000000)M followers"
        }
        return NSAttributedString(string: followerCountString, attributes: Configurations.followerCountLabelTextAttributes)
    }
        
    private let followerCountFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    private let pfpView = ProfilePictureView(outlineWidth: 2)
    private let messagePreviewLabel = UILabel()
    private let userRealNameLabel = UILabel()
    private let followerCountLabel = UILabel()
    private let unreadRequestDot = UIView()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up the background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        self.backgroundView = backgroundView
        
        // Set up the selected background view
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Configurations.selectedBackgroundViewBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView
        
        // Set up story view
        self.contentView.addSubview(self.pfpView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Configurations.pfpViewLeadingSpacing),
                $0.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                $0.widthAnchor.constraint(equalToConstant: Configurations.pfpViewSize.width),
                $0.heightAnchor.constraint(equalToConstant: Configurations.pfpViewSize.height)
            ])
        }
        
        // Set up the message preview label
        self.messagePreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.messagePreviewLabel)
        NSLayoutConstraint.activate([
            self.messagePreviewLabel.centerYAnchor.constraint(equalTo: self.pfpView.centerYAnchor),
            self.messagePreviewLabel.leadingAnchor.constraint(equalTo: self.pfpView.trailingAnchor, constant: Configurations.messagePreviewLabelLeadingSpacing)
        ])
        
        // Set up the user real name label
        self.userRealNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.userRealNameLabel)
        NSLayoutConstraint.activate([
            self.userRealNameLabel.leadingAnchor.constraint(equalTo: self.messagePreviewLabel.leadingAnchor),
            self.userRealNameLabel.bottomAnchor.constraint(equalTo: self.messagePreviewLabel.topAnchor, constant: -Configurations.userRealNameLabelBottomSpacing)
        ])
        
        // Set up the follower count label
        self.followerCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.followerCountLabel)
        NSLayoutConstraint.activate([
            self.followerCountLabel.leadingAnchor.constraint(equalTo: self.messagePreviewLabel.leadingAnchor),
            self.followerCountLabel.topAnchor.constraint(equalTo: self.messagePreviewLabel.bottomAnchor, constant: Configurations.followerCountLabelTopSpacing)
        ])
        
        // Set up the unread request dot
        self.unreadRequestDot.translatesAutoresizingMaskIntoConstraints = false
        self.unreadRequestDot.backgroundColor = Configurations.unreadRequestDotBackgroundColor
        self.unreadRequestDot.layer.cornerRadius = Configurations.unreadRequestDotSize.width / 2
        self.contentView.addSubview(self.unreadRequestDot)
        NSLayoutConstraint.activate([
            self.unreadRequestDot.centerYAnchor.constraint(equalTo: self.messagePreviewLabel.centerYAnchor),
            self.unreadRequestDot.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Configurations.unreadRequestDotTrailingSpacing),
            self.unreadRequestDot.widthAnchor.constraint(equalToConstant: Configurations.unreadRequestDotSize.width),
            self.unreadRequestDot.heightAnchor.constraint(equalToConstant: Configurations.unreadRequestDotSize.height)
        ])
        self.unreadRequestDot.isHidden = true
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    // Selected background view configurations
    static let selectedBackgroundViewBackgroundColor = UIColor(named: "DMCellSelectedBackgroundColor")!
    
    
    // Profile Picture view configurations
    static let pfpViewLeadingSpacing: CGFloat = 12
    static let pfpViewSize = CGSize.sqaure(size: 64)
    
    // Message preview label configurations
    static let messagePreviewLabelLeadingSpacing = screenWidth * 0.03333
    static let messagePreviewReadTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white.withAlphaComponent(0.6),
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0385, weight: .regular)
    ]
    static let messagePreviewUnreadTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0385, weight: .semibold)
    ]
    static let messagePreviewTimestampTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white.withAlphaComponent(0.6),
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0385, weight: .regular)
    ]
    
    // User real name label configurations
    static let userRealNameLabelBottomSpacing = screenWidth * 0.005
    static let userRealNameLabelReadTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0385, weight: .regular)
    ]
    static let userRealNameLabelUnreadTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0385, weight: .semibold)
    ]
    static let unreadRequestVerifiedIcon = UIImage(named: "VerifiedIcon")!.resizedTo(size: CGSize.sqaure(size: (userRealNameLabelUnreadTextAttributes[.font] as! UIFont).capHeight * 1.25))
    static let readRequestVerifiedIcon = UIImage(named: "VerifiedIcon")!.resizedTo(size: CGSize.sqaure(size: (userRealNameLabelReadTextAttributes[.font] as! UIFont).capHeight * 1.25))
    
    // User follower count label configurations
    static let followerCountLabelTopSpacing = userRealNameLabelBottomSpacing
    static let followerCountLabelTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white.withAlphaComponent(0.6),
        .font: UIFont.systemFont(ofSize: screenWidth * 0.035, weight: .regular)
    ]
    
    // Unread request dot configurations
    static let unreadRequestDotBackgroundColor = UIColor(named: "DMBlue")!
    static let unreadRequestDotSize = CGSize.sqaure(size: screenWidth * 0.021)
    static let unreadRequestDotTrailingSpacing = screenWidth * 0.03972
}
