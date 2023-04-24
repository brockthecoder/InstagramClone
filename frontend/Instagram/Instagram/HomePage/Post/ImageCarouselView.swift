//
//  ImageCarouselView.swift
//  Instagram
//
//  Created by brock davis on 3/5/23.
//

import UIKit

class ImageCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var images: [UIImage] = [] {
        didSet {
            self.collectionView.bounces = images.count > 1
            self.pageIndexLabel.isHidden = images.count <  2
            self.pageIndexLabelNeedsDisplay = true
            self.collectionView.reloadData()
        }
    }
    
    var hasUserTags: [Bool] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var currentIndex: Int = 0 {
        didSet {
            self.userPaged(to: currentIndex, from: oldValue)
        }
    }
    
    var delegate: ImageCarouselViewDelegate?
    
    private let collectionView: UICollectionView
    private var collectionViewObserveToken: NSKeyValueObservation!
    private let cellID = "imageCell"
    private let imageViewTag = 333
    private let taggedUsersButtonTag = 777
    private let pageIndexLabel = UILabel()
    private var pageIndexLabelNeedsDisplay = true
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = .black
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
        
        self.addSubview(self.collectionView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        self.collectionViewObserveToken = self.collectionView.observe(\.contentOffset, options: [.new]) { cv, _ in
            guard self.frame.width != 0 else { return }
            let currentPage = Int((cv.contentOffset.x / self.frame.width).rounded())
            if currentPage != self.currentIndex {
                self.currentIndex = currentPage
            }
        }
        
        self.pageIndexLabel.textAlignment = .center
        self.addSubview(self.pageIndexLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.pageIndexLabelBackgroundColor
            $0.layer.cornerRadius = Configurations.pageIndexLabelCornerRadius
            $0.layer.masksToBounds = true
            NSLayoutConstraint.activate([
                $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Configurations.pageIndexLabelTrailingConstant),
                $0.topAnchor.constraint(equalTo: self.topAnchor, constant: Configurations.pageIndexLabelTopConstant),
                $0.widthAnchor.constraint(equalToConstant: Configurations.pageIndexLabelSize.width),
                $0.heightAnchor.constraint(equalToConstant: Configurations.pageIndexLabelSize.height)
            ])
        }
    }
    
    override func didMoveToWindow() {
        self.window?.layoutIfNeeded()
        self.animateUserTags(for: 0)
        self.updatePageIndexLabel(to: 0)
        if self.pageIndexLabelNeedsDisplay {
            self.animatePageIndexLabel()
            self.pageIndexLabelNeedsDisplay = false
        }
    }
    
    
    private func userPaged(to pageIndex: Int, from prevPageIndex: Int) {
        self.delegate?.userDidPageTo(newPage: pageIndex)
        self.removeUserTagAnimations(for: prevPageIndex)
        self.animateUserTags(for: pageIndex)
        self.updatePageIndexLabel(to: pageIndex)
    }
    
    private func updatePageIndexLabel(to pageIndex: Int) {
        self.pageIndexLabel.attributedText = NSAttributedString(string: "\(pageIndex + 1)/\(self.collectionView.numberOfItems(inSection: 0))", attributes: Configurations.pageIndexLabelTextAttributes)
    }
    
    private func animatePageIndexLabel() {
        self.pageIndexLabel.layer.opacity = 1
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.beginTime = CACurrentMediaTime() + 5.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.pageIndexLabel.layer.opacity = 0
            self.pageIndexLabel.layer.removeAnimation(forKey: #keyPath(CALayer.opacity))
        }
        self.pageIndexLabel.layer.add(animation, forKey: #keyPath(CALayer.opacity))
        CATransaction.commit()
        
    }
    
    private func animateUserTags(for pageIndex: Int) {
        if self.hasUserTags.count > pageIndex && self.hasUserTags[pageIndex] {
            if let userTagsButton = self.collectionView.cellForItem(at: IndexPath(item: pageIndex, section: 0))?.contentView.viewWithTag(self.taggedUsersButtonTag) {
                userTagsButton.layer.opacity = 1
                let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
                animation.fromValue = 1
                animation.toValue = 0
                animation.duration = 0.5
                animation.beginTime = CACurrentMediaTime() + 4.0
                animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    if userTagsButton.layer.presentation()?.opacity == 0.0 {
                        userTagsButton.layer.opacity = 0.0
                        userTagsButton.layer.removeAnimation(forKey: #keyPath(CALayer.opacity))
                    }
                }
                userTagsButton.layer.add(animation, forKey: #keyPath(CALayer.opacity))
                CATransaction.commit()
            }
        }
    }
    
    private func removeUserTagAnimations(for pageIndex: Int) {
        if let taggedUsersButton = self.collectionView.cellForItem(at: IndexPath(item: pageIndex, section: 0))?.contentView.viewWithTag(self.taggedUsersButtonTag) {
            taggedUsersButton.layer.removeAnimation(forKey: #keyPath(CALayer.opacity))
            taggedUsersButton.layer.opacity = 0.0
        }
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath)
        
        // Add image view if missing
        if cell.contentView.viewWithTag(self.imageViewTag) == nil {
            cell.contentView.addSubview(UIImageView()) {
                $0.tag = self.imageViewTag
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    $0.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    $0.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    $0.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
            }
        }
        
        // Add tagged users button if missing
        if cell.contentView.viewWithTag(self.taggedUsersButtonTag) == nil {
            let button = UIButton()
            button.setBackgroundImage(Configurations.taggedUsersButtonBackgroundImage, for: .normal)
            cell.contentView.addSubview(button) {
                $0.tag = self.taggedUsersButtonTag
                $0.layer.opacity = 0
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Configurations.taggedUsersButtonLeadingConstant),
                    $0.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: Configurations.taggedUsersButtonBottomConstant)
                ])
            }
        }
        
        let imageView = cell.contentView.viewWithTag(self.imageViewTag) as! UIImageView
        imageView.image = self.images[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
}

private struct Configurations {
    
    static let taggedUsersIconSize = CGSize.sqaure(size: 10)
    static let taggedUsersIcon = UIImage(named: "HomePage/Feed/Post/taggedUsersIcon")!.resizedTo(size: taggedUsersIconSize).withTintColor(.white)
    static let taggedUsersButtonSize = CGSize.sqaure(size: 26)
    static let taggedUsersButtonBackgroundColor = UIColor(named: "HomePage/Feed/Post/overlayButtonBackgroundColor")!.withAlphaComponent(0.9)
    static let taggedUsersButtonShadowOpacity: Float = 0.3
    static let taggedUsersButtonShadowOffset = CGSize(width: 1.5 / 3.0, height: 1.5 / 3.0)
    static let taggedUsersButtonBackgroundImage = {
        return UIGraphicsImageRenderer(size: taggedUsersButtonSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(taggedUsersButtonBackgroundColor.cgColor)
            let backgroundRect = CGRect(origin: .zero, size: taggedUsersButtonSize)
            context.addEllipse(in: backgroundRect)
            context.fillPath()
            taggedUsersIcon.draw(at: CGPoint(x: backgroundRect.midX - (taggedUsersIconSize.width / 2), y: backgroundRect.midY - (taggedUsersIconSize.height / 2)))
        }
    }()
    static let taggedUsersButtonLeadingConstant: CGFloat = 14.0
    static let taggedUsersButtonBottomConstant: CGFloat = -14.0
    
    static let pageIndexLabelBackgroundColor = UIColor(named: "HomePage/Feed/Post/overlayButtonBackgroundColor")!.withAlphaComponent(0.9)
    
    static let pageIndexLabelTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: 14, weight: .regular)
    ]
    
    static let pageIndexLabelCornerRadius: CGFloat = 12.0
    
    static let pageIndexLabelTrailingConstant: CGFloat = -14.0
    
    static let pageIndexLabelTopConstant: CGFloat = 14.0
    
    static let pageIndexLabelSize = CGSize(width: 34, height: 26)
}

protocol ImageCarouselViewDelegate {
    
    func userDidPageTo(newPage index: Int)
}
