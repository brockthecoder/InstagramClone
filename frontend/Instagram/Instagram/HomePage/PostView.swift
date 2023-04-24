//
//  PostView.swift
//  Instagram
//
//  Created by brock davis on 3/5/23.
//

import UIKit

class PostView: UICollectionViewCell, ImageCarouselViewDelegate, CreatorCaptionViewDelegate {

    // Post header section
    private let pfpView = ProfilePictureView(outlineWidth: 2)
    private let usernameButton = UIButton()
    private var usernameButtonCenterYConstraint: NSLayoutConstraint!
    private let titleButton = UIButton()
    private let menuOptionsButton = UIButton()
    
    // Content section
    private var mediaView = UIView()
    private let mediaContentTag = 777
    private var mediaViewHeightAnchor: NSLayoutConstraint!
    private var mediaViewTopAnchor: NSLayoutConstraint!
    private let carouselPageIndicator = CarouselPageIndicatorView()
    
    // Actions section
    private let likeButton = UIButton()
    private let commentButton = UIButton()
    private let shareButton = UIButton()
    private let saveButton = UIButton()
    
    // like count
    private let likeCountView = PostLikeCountView()
    
    // Comments section
    private let creatorCaption = CreatorCaptionView()
    private var creatorCaptionTopConstraint: NSLayoutConstraint!
    private let commentCountButton = UIButton()
    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    private let topCommentViews = [TopCommentView(), TopCommentView()]
    
    // timestamp
    private let timestampLabel = UILabel()
    
    var post: FeedPost? {
        didSet {
            if let post {
                self.pfpView.profilePicture = post.creator.profilePictureImage
                self.pfpView.storyStatus = post.creator.hasStory ? .unseen : .none
                self.usernameButton.setAttributedTitle(self.usernameText(for: post.creator, postType: post.type), for: .normal)
                let titleText = self.titleText(for: post)
                if titleText.length == 0 {
                    self.usernameButtonCenterYConstraint.constant = Configurations.isolatedUsernameButtonCenterYConstant
                    self.titleButton.isHidden = true
                } else {
                    self.titleButton.isHidden = false
                    self.usernameButtonCenterYConstraint.constant = Configurations.usernameButtonCenterYConstant
                    self.titleButton.setAttributedTitle(titleText, for: .normal)
                }
                self.likeCountView.post = post
                self.creatorCaptionTopConstraint.constant = self.likeCountView.hasAttachment ? Configurations.creatorCaptionLargeTopConstant : Configurations.creatorCaptionRegularTopConstant
                self.creatorCaption.post = post
                self.carouselPageIndicator.isHidden = true
                for (ix, topCommentView) in topCommentViews.enumerated() {
                        topCommentView.comment = ix < post.topComments.count ? post.topComments[ix] : nil
                }
                self.setNeedsLayout()
                
                // Update timestamp
                self.timestampLabel.attributedText = self.timestampText(for: post.timestamp)
                
                // Update comment count text
                if post.commentCount == 0 { self.commentCountButton.setAttributedTitle(nil, for: .normal) }
                else { self.commentCountButton.setAttributedTitle(NSAttributedString(string: "View all \(self.numberFormatter.string(from: NSNumber(value: post.commentCount)) ?? "") comments", attributes: Configurations.commentCountTextAttributes), for: .normal) }
                
                func addSubviewToMediaView(subview: UIView) {
                    self.mediaView.addSubview(subview) {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        $0.tag = self.mediaContentTag
                        NSLayoutConstraint.activate([
                            $0.leadingAnchor.constraint(equalTo: self.mediaView.leadingAnchor),
                            $0.topAnchor.constraint(equalTo: self.mediaView.topAnchor),
                            $0.trailingAnchor.constraint(equalTo: self.mediaView.trailingAnchor),
                            $0.bottomAnchor.constraint(equalTo: self.mediaView.bottomAnchor),
                        ])
                    }
                }
                
                // Set up the media view
                switch post.type {
                // Image Carousel
                case .imageCarousel, .singleImage:
                    self.mediaViewHeightAnchor = self.mediaViewHeightAnchor.replaceWithNewMultiplier(post.aspectHeightMultiplier)
                    if !(self.mediaView.subviews.first is ImageCarouselView) {
                        self.mediaView.subviews.first?.removeFromSuperview()
                        addSubviewToMediaView(subview: ImageCarouselView())
                        self.mediaViewTopAnchor.constant = Configurations.imageContentTopConstant
                    }
                    let carouselView = self.mediaView.subviews.first as! ImageCarouselView
                    carouselView.delegate = self
                    let images = post.images()
                    carouselView.images = images
                    carouselView.hasUserTags = post.hasUserTags
                    self.carouselPageIndicator.isHidden = images.count < 2
                    self.carouselPageIndicator.currentPage = 0
                    self.carouselPageIndicator.numberOfPages = min(images.count, 5)
                case .reel:
                    if !(self.mediaView.subviews.first is ReelPostPlayerView) {
                        self.mediaViewHeightAnchor = self.mediaViewHeightAnchor.replaceWithNewMultiplier(1.585)
                        self.mediaView.subviews.first?.removeFromSuperview()
                        addSubviewToMediaView(subview: ReelPostPlayerView())
                        self.mediaViewTopAnchor.constant = 0
                    }
                    let reelPlayerView = self.mediaView.subviews.first as! ReelPostPlayerView
                    reelPlayerView.asset = post.assets().first!
                    reelPlayerView.hasTaggedUsers = post.hasUserTags.first!
                default:
                    break
                }
            }
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.layoutIfNeeded()
        
        layoutAttributes.size = CGSize(width: layoutAttributes.size.width, height: self.timestampLabel.frame.maxY + Configurations.cellBottomSpacingConstant)
        return layoutAttributes
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let container = self.contentView
        container.backgroundColor = .black
        
        // Media view
        container.addSubview(self.mediaView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.mediaViewHeightAnchor = $0.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1)
            self.mediaViewTopAnchor = $0.topAnchor.constraint(equalTo: container.topAnchor, constant: 0)
            NSLayoutConstraint.activate([
                self.mediaViewHeightAnchor,
                self.mediaViewTopAnchor,
                $0.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        }
        
        // Post header section
        container.addSubview(self.pfpView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.shadowRadius = 1.0
            $0.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            $0.layer.shadowOpacity = 0.3
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Configurations.pfpViewLeadingConstant),
                $0.topAnchor.constraint(equalTo: container.topAnchor, constant: Configurations.pfpViewTopConstant),
                $0.widthAnchor.constraint(equalToConstant: Configurations.pfpViewSize.width),
                $0.heightAnchor.constraint(equalToConstant: Configurations.pfpViewSize.height)
            ])
        }
        
        container.addSubview(self.usernameButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.shadowRadius = 1.0
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
            $0.layer.shadowOpacity = 0.3
            self.usernameButtonCenterYConstraint = $0.centerYAnchor.constraint(equalTo: self.pfpView.centerYAnchor, constant: Configurations.usernameButtonCenterYConstant)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.pfpView.trailingAnchor, constant: Configurations.usernameButtonLeadingConstant),
                self.usernameButtonCenterYConstraint
            ])
        }
        
        container.addSubview(self.titleButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.shadowRadius = 1.0
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
            $0.layer.shadowOpacity = 0.3
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.pfpView.trailingAnchor, constant: Configurations.titleButtonLeadingConstant),
                self.titleButton.topAnchor.constraint(equalTo: self.usernameButton.bottomAnchor, constant: Configurations.titleButtonTopConstant)
            ])
        }
        
        self.menuOptionsButton.setBackgroundImage(Configurations.optionsButtonBackgroundImage, for: .normal)
        container.addSubview(self.menuOptionsButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.shadowRadius = 1.0
            $0.layer.shadowOffset = CGSize(width: 1, height: 1)
            $0.layer.shadowOpacity = 0.3
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: container.trailingAnchor, constant: Configurations.optionsButtonCenterXOffset),
                $0.centerYAnchor.constraint(equalTo: container.topAnchor, constant: Configurations.optionsButtonCenterYOffset)
            ])
        }
        
        // Actions section
        self.likeButton.setBackgroundImage(Configurations.likeButtonUnselectedBackgroundImage, for: .normal)
        self.likeButton.setBackgroundImage(Configurations.likeButtonSelectedBackgroundImage, for: .selected)
        self.likeButton.addTarget(self, action: #selector(self.likeButtonTapped), for: .touchUpInside)
        container.addSubview(self.likeButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Configurations.likeButtonLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.mediaView.bottomAnchor, constant: Configurations.likeButtonTopConstant)
            ])
        }
        
        self.commentButton.setBackgroundImage(Configurations.commentButtonBackgroundImage, for: .normal)
        container.addSubview(self.commentButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.likeButton.trailingAnchor, constant: Configurations.commentButtonLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.likeButton.centerYAnchor)
            ])
        }
        
        self.shareButton.setBackgroundImage(Configurations.shareButtonBackgroundImage, for: .normal)
        container.addSubview(self.shareButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.commentButton.trailingAnchor, constant: Configurations.shareButtonLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.commentButton.centerYAnchor)
            ])
        }
        
        self.saveButton.setBackgroundImage(Configurations.saveButtonUnselectedBackgroundImage, for: .normal)
        self.saveButton.setBackgroundImage(Configurations.saveButtonSelectedBackgroundImage, for: .selected)
        self.saveButton.addTarget(self, action: #selector(self.saveButtonTapped), for: .touchUpInside)
        container.addSubview(self.saveButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerYAnchor.constraint(equalTo: self.likeButton.centerYAnchor),
                $0.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: Configurations.saveButtonTrailingConstant)
            ])
        }
        
        container.addSubview(self.carouselPageIndicator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerYAnchor.constraint(equalTo: self.likeButton.centerYAnchor, constant: Configurations.carouselPageIndicatorCenterYConstant),
                $0.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ])
        }
        
        container.addSubview(self.likeCountView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Configurations.likeCountLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.likeButton.bottomAnchor, constant: Configurations.likeCountTopConstant),
                $0.trailingAnchor.constraint(equalTo: self.saveButton.trailingAnchor)
            ])
        }
        
        self.creatorCaption.delegate = self
        container.addSubview(self.creatorCaption) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.creatorCaptionTopConstraint = $0.topAnchor.constraint(equalTo: self.likeCountView.bottomAnchor, constant: Configurations.creatorCaptionRegularTopConstant)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Configurations.creatorCaptionLeadingConstant),
                self.creatorCaptionTopConstraint,
                $0.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: Configurations.creatorCaptionTrailingConstant)
            ])
        }
        
        container.addSubview(self.commentCountButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Configurations.commmentCountButtonLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.creatorCaption.bottomAnchor, constant: Configurations.commentCountButtonTopConstant)
            ])
        }
        
        // Use manual layout for top comment views
        topCommentViews.forEach { container.addSubview($0) }
        
        
        // Use manual layout for timestamp label
        container.addSubview(self.timestampLabel)
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout top comment views
        var prevCommentView: UIView?
        for view in topCommentViews {
            let height = view.intrinsicContentSize.height
            let width = self.bounds.width - Configurations.topCommentsViewLeadingConstant
            let yOrigin: CGFloat
            if let prevCommentView {
                // Only add row spacing when comment view has content
                yOrigin = prevCommentView.frame.maxY + (height == 0.0 ? 0.0 : Configurations.topCommentsRowSpacing)
            }
            else {
                yOrigin = self.commentCountButton.frame.maxY + (height == 0.0 ? 0.0 : Configurations.topCommentsViewTopConstant)
            }
            view.frame = CGRect(x: Configurations.topCommentsViewLeadingConstant, y: yOrigin, width: width, height: height)
            prevCommentView = view
        }
        
        // Layout timestamp label
        let timestampYOrigin = self.topCommentViews.first!.frame.height == 0 ? self.commentCountButton.frame.maxY : prevCommentView!.frame.maxY + Configurations.topCommentsRowSpacing
        self.timestampLabel.frame = CGRect(x: Configurations.timestampLabelLeadingConstant, y: timestampYOrigin , width: self.timestampLabel.intrinsicContentSize.width, height: self.timestampLabel.intrinsicContentSize.height)
    }
    
    private func usernameText(for creator: FeedUser, postType: PostType) -> NSAttributedString {
        let text = NSMutableAttributedString(string: creator.username + " ", attributes: Configurations.usernameButtonTextAttributes)
        if creator.isVerified {
            let iconFillColor = postType == .reel ? UIColor.white : Configurations.regularVerifiedIconFillColor
            let verifiedAttachment = NSTextAttachment(image: Configurations.verifiedIcon.withTintColor(iconFillColor))
            verifiedAttachment.bounds = CGRect(origin: Configurations.verifiedIconAttachmentOrigin, size: verifiedAttachment.image!.size)
            text.append(NSAttributedString(attachment: verifiedAttachment))
        }
        return text
    }
    
    private func titleText(for post: FeedPost) -> NSAttributedString {
        switch post.type {
        case .reel:
            let audio = post.audio!
            let text = NSMutableAttributedString(string: audio.artistDisplayName, attributes: Configurations.titleButtonTextAttributes)
            text.addAttribute(.kern, value: -1.0 / 3.0, range: NSMakeRange(text.length - 1, 1))
            text.append(Configurations.reelsAudioSeperator)
            text.append(NSAttributedString(string: "" + audio.audioTitle, attributes: Configurations.titleButtonTextAttributes))
            if audio.explicit {
                let attachment = NSTextAttachment(image: Configurations.explicitIconWithLeftSpacing)
                attachment.bounds = CGRect(x: 0, y: -1.2, width: attachment.image!.size.width, height: attachment.image!.size.height)
                text.append(NSAttributedString(attachment: attachment))
            }
            return text
        case .sponsoredImageCarousel, .singleSponsoredImage:
            return NSAttributedString(string: "Sponsored", attributes: Configurations.sponsoredTitleButtonTextAttributes)
        default:
            if let location = post.location {
                return NSAttributedString(string: location.city + ", " + location.state, attributes: Configurations.titleButtonTextAttributes)
            }
            return NSAttributedString(string: "")
        }
    }
    
    private func timestampText(for timestamp: Date) -> NSAttributedString {
        // Get timestamp Components
        let timestampComponents = Calendar.current.dateComponents([.year, .month, .day], from: timestamp)
        
        // Get current time and year
        let now = Date()
        let currentYear = Calendar.current.dateComponents([.year], from: now).year!
        
        // Get seconds, minutes, hours, and days since the post timestamp
        let differenceComponents = Calendar.current.dateComponents([.second, .minute, .hour, .day], from: timestamp, to: now)
        
        // Return value
        let timestampText: NSAttributedString
        
        // Calculate text based on difference components
        if let daysAgo = differenceComponents.day, daysAgo > 7 && currentYear != timestampComponents.year {
            timestampText = NSAttributedString(string: "\(Calendar.current.monthSymbols[timestampComponents.month!]) \(timestampComponents.day!), \(timestampComponents.year!)", attributes: Configurations.timestampTextAttributes)
        }
        else if let daysAgo = differenceComponents.day, daysAgo > 7 {
            timestampText = NSAttributedString(string: "\(Calendar.current.monthSymbols[timestampComponents.month! - 1]) \(timestampComponents.day!)", attributes: Configurations.timestampTextAttributes)
        }
        else if differenceComponents.day == 7 {
            timestampText = NSAttributedString(string: "1 week ago", attributes: Configurations.timestampTextAttributes)
        }
        else if let daysAgo = differenceComponents.day, daysAgo >= 1 {
            timestampText = NSAttributedString(string: "\(daysAgo) day\(daysAgo < 2 ? "" : "s") ago", attributes: Configurations.timestampTextAttributes)
        }
        else if let hoursAgo = differenceComponents.hour, hoursAgo >= 1 {
            timestampText = NSAttributedString(string: "\(hoursAgo) hour\(hoursAgo < 2 ? "" : "s") ago", attributes: Configurations.timestampTextAttributes)
        }
        else if let minutesAgo = differenceComponents.minute, minutesAgo < 60 {
            timestampText = NSAttributedString(string: "\(minutesAgo) minute\(minutesAgo < 2 ? "" : "s") ago", attributes: Configurations.timestampTextAttributes)
        }
        else {
            let secondsAgo = differenceComponents.second!
            timestampText = NSAttributedString(string: "\(secondsAgo) second\(secondsAgo < 2 ? "" : "s") ago", attributes: Configurations.timestampTextAttributes)
        }
        return timestampText
     }
    
    func willDisplay(in collectionView: UICollectionView) {
        
        
        guard
            let post = self.post,
            post.type == .reel,
            let reelPlayerView = self.mediaView.viewWithTag(self.mediaContentTag) as? ReelPostPlayerView,
            let feedController = self.parentViewController as? HomePageFeedController
        else {
            return
        }
        feedController.addReelPlayerToQueue(reelPlayerView, from: self)
    }
    
    func didEndDisplaying(in collectionView: UICollectionView) {
        guard
            let post = self.post,
            post.type == .reel,
            let reelPlayerView = self.mediaView.viewWithTag(self.mediaContentTag) as? ReelPostPlayerView,
            let feedController = self.parentViewController as? HomePageFeedController
        else {
            return
        }
        feedController.removeReelPlayerFromQueue(reelPlayerView)
    }
    
    func userDidPageTo(newPage index: Int) {
        self.carouselPageIndicator.currentPage = index
    }
    
    // CreatorCaptionViewDelegate conformance
    func userExpandedCaption(inCaptionView view: CreatorCaptionView) {
        if let cv = self.superview as? UICollectionView {
            let invalidationContext = UICollectionViewLayoutInvalidationContext()
            if let ixPath = cv.indexPath(for: self) {
                invalidationContext.invalidateItems(at: [ixPath])
            } else {
                invalidationContext.invalidateItems(at: cv.indexPathsForVisibleItems)
            }
            cv.collectionViewLayout.invalidateLayout(with: invalidationContext)
        }
    }
    
    @objc private func likeButtonTapped() {
        self.likeButton.isSelected.toggle()
    }
    
    @objc private func saveButtonTapped() {
        self.saveButton.isSelected.toggle()
    }
}

private struct Configurations {
    
    // Media view section
    
    static let imageContentTopConstant: CGFloat = 49.0
    
    static let carouselPageIndicatorCenterYConstant: CGFloat = -7.0 / 3.0
    
    // Header section
    static let pfpViewSize = CGSize.sqaure(size: 38)
    static let pfpViewLeadingConstant: CGFloat = 7.0
    static let pfpViewTopConstant: CGFloat = 8.0
    
    static let usernameButtonLeadingConstant: CGFloat = 19.0 / 3.0
    static let usernameButtonCenterYConstant: CGFloat = -8.0
    static let isolatedUsernameButtonCenterYConstant = -1.0
    static let usernameButtonTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
    ]
    static let verifiedIconSize = CGSize.sqaure(size: 10)
    static let verifiedIcon = UIImage(named: "HomePage/Feed/Post/verifiedIcon")!.resizedTo(size: verifiedIconSize)
    static let regularVerifiedIconFillColor = UIColor(named: "HomePage/Feed/Post/verifedIconFillColor")!
    static let verifiedIconAttachmentOrigin = CGPoint(x: 1.0 / 3.0, y: 2.0 / 3.0)
    
    static let titleButtonLeadingConstant: CGFloat = 7.0
    static let titleButtonTopConstant: CGFloat = -35.0 / 3.0
    static let titleButtonTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 14, weight: .regular)
    ]
    static let sponsoredTitleButtonTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 10, weight: .regular)
    ]
    
    static let reelsAudioSeperator = NSAttributedString(string: "・", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 12, weight: .regular),
        .baselineOffset: -1.0 / 3.0,
        .kern: -1.0 / 3.0
    ])
    
    static let explicitIconSize = CGSize.sqaure(size: 12)
    static let explicitIconLeftSpacing: CGFloat = 6.0
    static let explicitIconFillColor = UIColor.white.withAlphaComponent(0.5)
    static let explicitIcon = UIImage(named: "HomePage/Feed/Post/explicitIcon")!.resizedTo(size: explicitIconSize).withTintColor(explicitIconFillColor)
    static let explicitIconWithLeftSpacing = UIGraphicsImageRenderer(size: CGSize(width: explicitIconLeftSpacing + explicitIconSize.width, height: explicitIconSize.height)).image{ _ in
        explicitIcon.draw(at: CGPoint(x: explicitIconLeftSpacing, y: 0))
    }
    
    static let optionsIconSize = CGSize(width: 15, height: 3)
    static let optionsIcon = UIImage(named: "HomePage/Feed/Post/menuOptionsIcon")!.resizedTo(size: optionsIconSize).withTintColor(.white)
    static let optionsButtonSize = CGSize.sqaure(size: 39)
    static let optionsButtonCenterXOffset: CGFloat = -22.0
    static let optionsButtonCenterYOffset: CGFloat = 22.0
    static let optionsButtonBackgroundImage = UIGraphicsImageRenderer(size: optionsButtonSize).image { _ in
        optionsIcon.draw(at: CGPoint(x: (optionsButtonSize.width / 2) - (optionsIconSize.width / 2), y: (optionsButtonSize.height / 2) - (optionsIconSize.height / 2)))
    }
    
    // Actions section
    static let actionButtonFillColor = UIColor(named: "HomePage/Feed/Post/actionButtonFillColor")!
    static let likeButtonSize = CGSize(width: 23, height: 20)
    static let likeButtonUnselectedBackgroundImage = UIImage(named: "HomePage/Feed/Post/likeIcon")!.resizedTo(size: likeButtonSize).withTintColor(actionButtonFillColor)
    static let likeButtonSelectedBackgroundImage = UIImage(named: "HomePage/Feed/Post/unlikeIcon")!.resizedTo(size: likeButtonSize)
    static let likeButtonLeadingConstant: CGFloat = 44.0 / 3.0
    static let likeButtonTopConstant: CGFloat = 14.0
    
    static let commentButtonSize = CGSize.sqaure(size: 22)
    static let commentButtonBackgroundImage = UIImage(named: "HomePage/Feed/Post/commentIcon")!.resizedTo(size: commentButtonSize).withTintColor(actionButtonFillColor)
    static let commentButtonLeadingConstant: CGFloat = 18.0
    
    static let shareButtonSize = CGSize(width: 22, height: 20)
    static let shareButtonBackgroundImage = UIImage(named: "HomePage/Feed/Post/shareIcon")!.resizedTo(size: shareButtonSize).withTintColor(actionButtonFillColor)
    static let shareButtonLeadingConstant: CGFloat = 18.0
    
    static let saveButtonSize = CGSize(width: 18, height: 20)
    static let saveButtonUnselectedBackgroundImage = UIImage(named: "HomePage/Feed/Post/saveIcon")!.resizedTo(size: saveButtonSize).withTintColor(actionButtonFillColor)
    static let saveButtonSelectedBackgroundImage = UIImage(named: "HomePage/Feed/Post/unsaveIcon")!.resizedTo(size: saveButtonSize).withTintColor(actionButtonFillColor)
    static let saveButtonTrailingConstant: CGFloat = -20.0
    
    // Like count
    static let likeCountTopConstant: CGFloat = 41.0 / 3.0
    static let likeCountLeadingConstant: CGFloat = 16.0
    
    // Comments section
    static let creatorCaptionLeadingConstant: CGFloat = 16.0
    static let creatorCaptionRegularTopConstant: CGFloat = 6.0
    static let creatorCaptionLargeTopConstant: CGFloat = 8.0
    static let creatorCaptionTrailingConstant: CGFloat = -24.0
    static let commmentCountButtonLeadingConstant: CGFloat = 16.0
    static let commentCountButtonTopConstant: CGFloat = 0.0
    
    static let commentCountTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "HomePage/Feed/Post/commentCountTextColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ]
    static let topCommentsViewLeadingConstant: CGFloat = 16.0
    static let topCommentsRowSpacing: CGFloat = 17.0 / 3.0
    static let topCommentsViewTopConstant: CGFloat = -1.0 / 3.0
    
    // Timestamp
    static let timestampTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "HomePage/Feed/Post/timestampTextColor")!,
        .font: UIFont.systemFont(ofSize: 14, weight: .regular)
    ]
    static let timestampLabelLeadingConstant: CGFloat = 16.0
    // Cell constants
    static let cellBottomSpacingConstant: CGFloat = 13.0
    
}
