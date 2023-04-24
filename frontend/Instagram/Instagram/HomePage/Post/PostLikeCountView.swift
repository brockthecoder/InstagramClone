//
//  PostLikeCountView.swift
//  Instagram
//
//  Created by brock davis on 3/6/23.
//

import UIKit

class PostLikeCountView: UIView, NSLayoutManagerDelegate {
    
    var hasAttachment = false

    var post: FeedPost? {
        didSet {
            self.textStorage.deleteCharacters(in: NSMakeRange(0, self.textStorage.length))
            self.hasAttachment = false
            self.layoutIfNeeded()
            if let post {
                
                // No likes = don't draw
                if post.likeCount == 0 {
                    self.drawingSize = .zero
                    return
                } else if !post.likeCountHidden && !post.topLikers.contains(where: { $0.activeUserFollows }) {
                    // Don't include any pfps
                    let countString = self.numberFormatter.string(from: post.likeCount as NSNumber) ?? "0"
                    self.textStorage.append(NSAttributedString(string: countString + " likes", attributes: Configurations.emphasizedTextAttributes))
                } else {
                    let topLikersFollowing = post.topLikers.filter( { $0.activeUserFollows })
                    var attachmentWidth: CGFloat = 0
                    if !topLikersFollowing.isEmpty {
                        let attachment = self.createTopLikersTextAttachment(for: topLikersFollowing)
                        attachment.bounds = CGRect(origin: Configurations.attachmentOrgin, size: attachment.image!.size)
                        attachmentWidth = attachment.image!.size.width
                        self.textStorage.append(NSAttributedString(attachment: attachment))
                        self.hasAttachment = true
                    }
                    self.textStorage.append(NSAttributedString(string: "Liked by ", attributes: Configurations.regularTextAttributes))
                    let topLiker = topLikersFollowing.isEmpty ? post.topLikers.first! : topLikersFollowing.first!
                    self.textStorage.append(NSAttributedString(string: topLiker.username, attributes: Configurations.emphasizedTextAttributes))
                    self.textStorage.append(NSAttributedString(string: " and ", attributes: Configurations.regularTextAttributes))
                    let countString = self.numberFormatter.string(from: (post.likeCount - 1) as NSNumber) ?? "0"
                    self.textStorage.append(NSAttributedString(string: countString + " others", attributes: Configurations.emphasizedTextAttributes))
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.headIndent = attachmentWidth
                    self.textStorage.addAttributes([.paragraphStyle: paragraphStyle], range: NSMakeRange(0, self.textStorage.length))
                }
                self.layoutManager.ensureLayout(for: self.textContainer)
                self.drawingSize = self.layoutManager.usedRect(for: self.textContainer).size
                self.invalidateIntrinsicContentSize()
                self.setNeedsDisplay()
            }
        }
    }
    
    private let numberFormatter: NumberFormatter
    private let textContainer = NSTextContainer(size: CGSize(width: 0, height: 100))
    private let textStorage = NSTextStorage()
    private let layoutManager = NSLayoutManager()
    private var drawingSize: CGSize = .zero
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.drawingSize.height)
    }

    required init(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        super.init(frame: .zero)
        self.contentMode = .redraw
        self.backgroundColor = .black
        self.textStorage.addLayoutManager(self.layoutManager)
        self.layoutManager.addTextContainer(self.textContainer)
        self.layoutManager.delegate = self
        self.textContainer.lineFragmentPadding = 0
    }
    
    override func draw(_ rect: CGRect) {
        self.layoutManager.drawBackground(forGlyphRange: NSMakeRange(0, self.layoutManager.numberOfGlyphs), at: .zero)
        self.layoutManager.drawGlyphs(forGlyphRange: NSMakeRange(0, self.layoutManager.numberOfGlyphs), at: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textContainer.size.width = self.bounds.size.width
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>, lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>, in textContainer: NSTextContainer, forGlyphRange glyphRange: NSRange) -> Bool {
        lineFragmentRect.pointee.size.height = (Configurations.regularTextAttributes[.font] as! UIFont).lineHeight + 2
        return true
    }
    
    private func createTopLikersTextAttachment(for topLikers: [FeedUser]) -> NSTextAttachment {
        // Calculate image size
        var imageSize = CGSize(width: 0, height: Configurations.topLikerPfpBackgroundSize.height + 2)
        for _ in topLikers {
            imageSize.width += (imageSize.width == 0) ? Configurations.topLikerPfpBackgroundSize.width : Configurations.additionalTopLikerOffset
        }
        imageSize.width += Configurations.attachmentToTextSpaceWidth - (4.0/3.0)
        let image = UIGraphicsImageRenderer(size: imageSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            
            var trailingOffset: CGFloat = Configurations.topLikerPfpBackgroundSize.width + Configurations.attachmentToTextSpaceWidth
            let backgroundTopOffset: CGFloat = (imageSize.height - Configurations.topLikerPfpBackgroundSize.height) + (4.0 / 3.0)
            UIColor.black.setFill()
            
            for topLiker in topLikers.reversed() {
                let ellipseRect = CGRect(x: imageSize.width - trailingOffset, y: backgroundTopOffset, width: Configurations.topLikerPfpBackgroundSize.width, height: Configurations.topLikerPfpBackgroundSize.height)
                context.fillEllipse(in: ellipseRect)
                let pfp = topLiker.profilePictureImage.resizedTo(size: Configurations.topLikerPfpSize)
                let pfpRect = CGRect(origin: CGPoint(x: ellipseRect.midX - (pfp.size.width / 2), y: ellipseRect.midY - (pfp.size.height / 2)), size: Configurations.topLikerPfpSize)
                context.addEllipse(in: pfpRect)
                context.clip()
                pfp.draw(in: pfpRect)
                context.resetClip()
                trailingOffset += Configurations.additionalTopLikerOffset
            }
        }
        return NSTextAttachment(image: image)
    }
}

private struct Configurations {
    
    // Top likers attachment
    static let topLikerPfpBackgroundSize = CGSize.sqaure(size: 21)
    static let topLikerPfpSize = CGSize.sqaure(size: 52.0 / 3.0)
    static let additionalTopLikerOffset: CGFloat = 13.0
    static let attachmentToTextSpaceWidth: CGFloat = 13.0 / 3.0
    static let attachmentOrgin = CGPoint(x: 0, y: UIFont.systemFont(ofSize: 16, weight: .regular).descender - 2)
    
    // Like text
    static let textColor = UIColor(named: "HomePage/Feed/Post/commentsAndLikesTextColor")!
    static let regularTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: textColor,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ]
    static let emphasizedTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: textColor,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
    ]
    
}
