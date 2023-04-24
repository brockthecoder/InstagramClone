//
//  TopCommentViewTableViewCell.swift
//  Instagram
//
//  Created by brock davis on 3/20/23.
//

import UIKit

class TopCommentView: UIView {
    
    private let label = UILabel()
    private let likeButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var comment: FeedPostComment? {
        didSet {
            self.label.attributedText = nil
            if let comment {
                let commentText = NSMutableAttributedString(string: comment.creatorUsername + " ", attributes: Configurations.usernameTextAttributes)
                commentText.append(NSAttributedString(string: comment.text, attributes: Configurations.commentTextAttributes))
                self.label.attributedText = commentText
                // Reposition button if like count changed
                self.setNeedsLayout()
            }
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init()
        self.frame = frame
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .black
        self.clipsToBounds = true
        self.likeButton.addTarget(self, action: #selector(self.userTappedLikeButton), for: .touchUpInside)
        self.likeButton.setImage(Configurations.likeIcon, for: .normal)
        self.likeButton.setImage(Configurations.unlikeIcon, for: .selected)
        self.label.numberOfLines = 3
        
        self.addSubview(label) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                $0.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            ])
        }
        
        self.addSubview(likeButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                $0.widthAnchor.constraint(equalToConstant: Configurations.likeButtonWidth),
                $0.heightAnchor.constraint(equalTo: self.label.heightAnchor)
            ])
        }
    }
    
    func prepareForReuse() {
        self.likeButton.isSelected = false
        self.label.attributedText = nil
    }
    
    @objc private func userTappedLikeButton() {
        self.likeButton.isSelected.toggle()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.label.intrinsicContentSize.height)
    }
}

private struct Configurations {
    
    static let likeButtonIconSize = CGSize(width: 12, height: 10)
    
    static let likeButtonWidth: CGFloat = likeButtonIconSize.width + 28.0
    
    static let likeIconColor = UIColor(named: "HomePage/Feed/Post/commentLikeButtonColor")!
    
    static let likeIcon = UIImage(named: "HomePage/Feed/Post/likeIcon")!.resizedTo(size: likeButtonIconSize).withTintColor(likeIconColor)
    
    static let unlikeIcon = UIImage(named: "HomePage/Feed/Post/unlikeIcon")!.resizedTo(size: likeButtonIconSize)
    
    static let usernameTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
    ]
        
    static let commentTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ]
}
