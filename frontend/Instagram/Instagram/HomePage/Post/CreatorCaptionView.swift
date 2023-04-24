//
//  CreatorCaptionView.swift
//  InstagramClone
//
//  Created by brock davis on 11/3/22.
//

import UIKit

class CreatorCaptionView: UIView {
    
    private let condensedCaption = NSMutableAttributedString()
    private let expandedCaption = NSMutableAttributedString()
    private let textStorage = NSTextStorage()
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer(size: CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude))
    private let tapRecognizer = UITapGestureRecognizer()

    var post: FeedPost? {
        didSet {
            self.expandedCaption.deleteCharacters(in: NSMakeRange(0, self.expandedCaption.length))
            self.condensedCaption.deleteCharacters(in: NSMakeRange(0, self.condensedCaption.length))
            self.textStorage.deleteCharacters(in: NSMakeRange(0, self.textStorage.length))
            if let post {
                
                // Need correct layout width for text container
                self.superview?.layoutIfNeeded()
                
                guard let caption = post.caption else { return }
                
                // Parse and attribute caption
                let attributedCaption = NSMutableAttributedString(string: caption, attributes: Configurations.captionAttributes)
                NSRegularExpression.hashtagMentionFinder.enumerateMatches(in: attributedCaption.string, range: NSMakeRange(0, attributedCaption.length)) { result, _, _ in
                    guard let result else { return }
                    let token = attributedCaption.mutableString.substring(with: result.range).trimmingCharacters(in: .whitespacesAndNewlines)
                    let attributeKey: NSAttributedString.Key = token.starts(with: "#") ? .hashtag : .mention
                    attributedCaption.addAttributes([
                        attributeKey: token,
                        .foregroundColor: Configurations.hashtagMentionForegroundColor
                    ], range: result.range)
                }
                // Prepend creator username to caption
                attributedCaption.insert(NSAttributedString(string: post.creator.username + " ", attributes: Configurations.creatorUsernameAttributes), at: 0)
                
                // Add full caption to expanded storage
                self.expandedCaption.append(attributedCaption)
                
                // Calculate and set condensed caption
                self.condensedCaption.append(self.condensedCaption(for: attributedCaption))
                
                // View displays condensed caption to start
                self.textStorage.append(self.condensedCaption)
                
            }
            // Notify to system to recalculate layout height
            self.invalidateIntrinsicContentSize()
        }
    }

    private func condensedCaption(for caption: NSAttributedString) -> NSAttributedString {
        
        let lm = NSLayoutManager()
        let ts = NSTextStorage(attributedString: caption)
        ts.addLayoutManager(lm)
        let tc = NSTextContainer(size: self.textContainer.size)
        tc.lineFragmentPadding = 0
        lm.addTextContainer(tc)
        
        guard lm.numberOfLines() > 2 else { return caption }
        
        
        // Delete caption in excess of 2 lines
        let glyphDeleteRange = NSRange(lm.glyphRangeForLineFragment(at: 2).location..<lm.numberOfGlyphs)
        ts.deleteCharacters(in: lm.characterRange(forGlyphRange: glyphDeleteRange, actualGlyphRange: nil))
        
        // Store second line character range
        let secondLineCharRange = lm.characterRange(forGlyphRange: lm.glyphRangeForLineFragment(at: 1), actualGlyphRange: nil)
        
        // Add "... more" text
        ts.append(Configurations.moreText)
        
        // Match words and their leading whitespace
        let matches = try! NSRegularExpression(pattern: "(\\s*\\b\\w+\\b)").matches(in: ts.string, range: secondLineCharRange)
        
        
        for word in matches.reversed() {
            ts.deleteCharacters(in: word.range)
            guard lm.numberOfLines() > 2 else {
                // Remove last whitespace
                if let trailingWSRange = try? NSRegularExpression(pattern: "(\\s+)(?=\\.\\.\\. more$)").firstMatch(in: ts.string, range: NSMakeRange(0, ts.length))?.range {
                    ts.deleteCharacters(in: trailingWSRange)
                }
                break
            }
        }
        
        return ts
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutManager.ensureLayout(for: self.textContainer)
        return CGSize(width: UIView.noIntrinsicMetric, height: self.layoutManager.usedRect(for: self.textContainer).height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textContainer.size.width = self.frame.width
    }

    var delegate: CreatorCaptionViewDelegate?
    
    override func draw(_ rect: CGRect) {
        let glyphRange = NSMakeRange(0, self.layoutManager.numberOfGlyphs)
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: .zero)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.contentMode = .redraw
        self.backgroundColor = .black
        self.tapRecognizer.addTarget(self, action: #selector(self.userTappedView))
        self.addGestureRecognizer(self.tapRecognizer)
        self.textStorage.addLayoutManager(self.layoutManager)
        self.layoutManager.addTextContainer(self.textContainer)
        self.textContainer.lineFragmentPadding = 0
    }
    
    @objc private func userTappedView(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        let tappedCharacterIndex = self.layoutManager.characterIndex(for: location, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let tappedCharacterAttrs = self.textStorage.attributes(at: tappedCharacterIndex, effectiveRange: nil)
        
        if let creatorUsername = tappedCharacterAttrs[Configurations.creatorKey] as? String {
            self.delegate?.userTappedCreatorUsername?(inCaptionView: self, creatorUsername: creatorUsername)
        } else if let hashtag = tappedCharacterAttrs[.hashtag] as? String {
            self.delegate?.userTappedHashtagText?(inCaptionView: self, hashtag: hashtag)
        } else if let mention = tappedCharacterAttrs[.mention] as? String {
            self.delegate?.userTappedMentionText?(inCaptionView: self, mentionedUsername: mention)
        } else if tappedCharacterAttrs[Configurations.moreKey] != nil {
            // Update storage to expanded caption
            self.textStorage.deleteCharacters(in: NSMakeRange(0, self.textStorage.length))
            self.textStorage.append(self.expandedCaption)
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay()
            self.delegate?.userExpandedCaption?(inCaptionView: self)
        } else {
            print("User tapped regular caption text")
        }
    }
}

private struct Configurations {
    
    static let creatorKey = NSAttributedString.Key("creator")
    static let creatorUsernameAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
    ]
    
    static let captionAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ]
    
    static let hashtagMentionForegroundColor = UIColor(named: "HomePage/Feed/Post/HashtagMentionHighlightColor")!
    static let moreForegroundColor = UIColor(named: "HomePage/Feed/Post/MoreForegroundColor")!
    static let moreKey = NSAttributedString.Key("more")
    
    static let moreText: NSAttributedString = {
        let moreText = NSMutableAttributedString(string: "... ", attributes: captionAttributes)
        moreText.append(NSAttributedString(string: "more", attributes: [
            .foregroundColor: moreForegroundColor,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]))
        moreText.addAttribute(moreKey, value: true, range: NSMakeRange(0, moreText.length))
        return moreText
    }()
}

@objc protocol CreatorCaptionViewDelegate{
    
    @objc optional func userExpandedCaption(inCaptionView view: CreatorCaptionView)
    
    @objc optional func userTappedMentionText(inCaptionView view: CreatorCaptionView, mentionedUsername username: String)
    
    @objc optional func userTappedHashtagText(inCaptionView view: CreatorCaptionView, hashtag: String)
    
    @objc optional func userTappedCreatorUsername(inCaptionView view: CreatorCaptionView, creatorUsername: String)
}
