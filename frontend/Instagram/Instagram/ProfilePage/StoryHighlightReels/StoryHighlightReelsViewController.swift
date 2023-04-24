//
//  StoryHighlightReelsViewController.swift
//  InstagramClone
//
//  Created by brock davis on 1/21/23.
//

import UIKit

class StoryHighlightReelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // No Highlight Reels
    private let infoView = UIView()
    private var infoViewBottomConstraint: NSLayoutConstraint!
    private let infoViewDivider = UIView()
    private let infoTitleLabel = UILabel()
    private let infoDescriptionLabel = UILabel()
    private let fullViewToggleIconView = UIImageView()
    private var toggleIconViewTopConstraint: NSLayoutConstraint!
    private let tapRecognizer = UITapGestureRecognizer()
    
    let collectionView: UICollectionView
    private let cellID = "storyHighlightReelCell"
    private let user = ActiveUser.loggedIn.first!
    
    private var rootViewBottomConstraint: NSLayoutConstraint!
    

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Configurations.itemSize
        layout.sectionInset = Configurations.sectionInset
        layout.minimumLineSpacing = Configurations.interItemSpacing
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        
        // Configure collection view
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = .black
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
        
        // Set up alternate layout if user has no highlights
        if user.storyHighlights.isEmpty {
            self.tapRecognizer.addTarget(self, action: #selector(self.userTappedInfoView))
            self.infoView.addGestureRecognizer(self.tapRecognizer)
            self.view.addSubview(self.infoView) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.infoViewLeadingSpacing),
                    $0.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Configurations.infoViewTopSpacing),
                    $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                ])
            }
            
            self.infoTitleLabel.attributedText = Configurations.titleText
            self.infoView.addSubview(self.infoTitleLabel) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.infoView.leadingAnchor),
                    $0.topAnchor.constraint(equalTo: self.infoView.topAnchor)
                ])
            }
            
            self.infoDescriptionLabel.attributedText = Configurations.descriptionText
            self.infoDescriptionLabel.numberOfLines = 2
            
            self.fullViewToggleIconView.image = Configurations.fullViewIcon
            self.toggleIconViewTopConstraint = self.fullViewToggleIconView.topAnchor.constraint(equalTo: self.infoView.topAnchor, constant: Configurations.fullViewIconCondensedTopSpacing)
            self.infoView.addSubview(self.fullViewToggleIconView) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.toggleIconViewTopConstraint,
                    $0.trailingAnchor.constraint(equalTo: self.infoView.trailingAnchor, constant: -Configurations.fullViewIconTrailingSpacing)
                ])
            }
            
            self.view.addSubview(self.infoViewDivider) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.backgroundColor = Configurations.infoViewDividerColor
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    $0.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -Configurations.infoViewDividerHeight),
                    $0.heightAnchor.constraint(equalToConstant: Configurations.infoViewDividerHeight)
                ])
            }
            
            self.infoViewBottomConstraint = self.infoView.bottomAnchor.constraint(equalTo: self.infoTitleLabel.bottomAnchor, constant: Configurations.infoViewBottomPadding)
            self.rootViewBottomConstraint = self.view.bottomAnchor.constraint(equalTo: self.infoView.bottomAnchor)
            
            // Size up the root view and info view
            NSLayoutConstraint.activate([
                self.infoViewBottomConstraint,
                self.view.widthAnchor.constraint(equalToConstant: Configurations.screenWidth),
                self.rootViewBottomConstraint
            ])
            
        } else {
            self.view.addSubview(self.collectionView)
            NSLayoutConstraint.activate([
                self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: Configurations.collectionViewCenterYOffset),
                self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.collectionView.heightAnchor.constraint(equalToConstant: Configurations.itemSize.height)
            ])
            
            // Size up the root view
            NSLayoutConstraint.activate([
                self.view.widthAnchor.constraint(equalToConstant: Configurations.screenWidth),
                self.view.heightAnchor.constraint(equalToConstant: Configurations.rootViewHeight)
            ])
        }
    }
    
    @objc private func userTappedInfoView() {
        if self.infoDescriptionLabel.superview != nil {
            self.infoDescriptionLabel.removeFromSuperview()
            self.collectionView.removeFromSuperview()
            self.fullViewToggleIconView.transform = .identity
            self.toggleIconViewTopConstraint.constant = Configurations.fullViewIconCondensedTopSpacing
            self.infoViewBottomConstraint.isActive = false
            self.infoViewBottomConstraint = self.infoView.bottomAnchor.constraint(equalTo: self.infoTitleLabel.bottomAnchor, constant: Configurations.infoViewBottomPadding)
            self.infoViewBottomConstraint.isActive = true
            self.rootViewBottomConstraint.isActive = false
            self.rootViewBottomConstraint = self.view.bottomAnchor.constraint(equalTo: self.infoView.bottomAnchor)
            self.rootViewBottomConstraint.isActive = true
            self.infoViewDivider.isHidden = false
        } else {
            self.infoView.addSubview(self.infoDescriptionLabel) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.infoTitleLabel.leadingAnchor),
                    $0.topAnchor.constraint(equalTo: self.infoTitleLabel.bottomAnchor, constant: Configurations.descriptionTextTopSpacing)
                ])
            }
            self.infoViewBottomConstraint.isActive = false
            self.infoViewBottomConstraint = self.infoView.bottomAnchor.constraint(equalTo: self.infoDescriptionLabel.bottomAnchor, constant: Configurations.infoViewBottomPadding)
            self.infoViewBottomConstraint.isActive = true
            
            self.view.addSubview(self.collectionView) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    $0.topAnchor.constraint(equalTo: self.infoView.bottomAnchor, constant: Configurations.infoCollectionViewTopSpacing),
                    $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    $0.heightAnchor.constraint(equalToConstant: Configurations.itemSize.height)
                ])
            }
            self.rootViewBottomConstraint.isActive = false
            self.rootViewBottomConstraint = self.view.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: Configurations.infoCollectionViewBottomSpacing)
            self.rootViewBottomConstraint.isActive = true
            self.fullViewToggleIconView.transform = CGAffineTransformMakeRotation(.pi)
            self.toggleIconViewTopConstraint.constant = Configurations.fullViewIconExpandedTopSpacing
            self.infoViewDivider.isHidden = true
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.user.storyHighlights.isEmpty ? 5 : self.user.storyHighlights.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath)
        
        // Check if this is user-populated or informational
        if self.user.storyHighlights.isEmpty {
            if indexPath.item == 0 {
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                
                let newReelView = NewStoryHighlightReelView()
                newReelView.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(newReelView)
                NSLayoutConstraint.activate([
                    newReelView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    newReelView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    newReelView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    newReelView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
                return cell
            }
            else {
                cell.contentView.subviews.forEach { $0.removeFromSuperview() }
                cell.contentView.addSubview(BlankStoryHighlightReelView()) {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                        $0.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                        $0.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                        $0.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                    ])
                }
                return cell
            }
        }
        
        // Check if cell is the new highlight cell (Last item in the collection)
        guard indexPath.item < ActiveUser.loggedIn.first!.storyHighlights.count else {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            let newReelView = NewStoryHighlightReelView()
            newReelView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(newReelView)
            NSLayoutConstraint.activate([
                newReelView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                newReelView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                newReelView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                newReelView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            return cell
        }
        
        // Add subiew to new cells
        if cell.contentView.subviews.isEmpty {
            let highlightReelView = StoryHighlightReelView()
            highlightReelView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(highlightReelView)
            NSLayoutConstraint.activate([
                highlightReelView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                highlightReelView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                highlightReelView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                highlightReelView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        }
        
        // Configure story highlight reel view data
        let highlightReelView = cell.contentView.subviews.first as! StoryHighlightReelView
        highlightReelView.highlightReel = ActiveUser.loggedIn.first!.storyHighlights[indexPath.item]
        
        return cell
        
    }

}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let sectionInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 9)
    
    static let itemSize = CGSize(width: 64, height: 83)
    
    static let interItemSpacing: CGFloat = 18
    
    static let rootViewHeight = screenWidth * 0.29516539440203562341
    
    static let collectionViewCenterYOffset = screenWidth * 0.00424088210347752332
    
    // No highlight reels
    
    static let titleTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/StoryHighlightReelView/NoHighlightReels/titleColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
    ]
    
    static let titleText = NSAttributedString(string: "Story highlights", attributes: titleTextAttributes)
    
    static let infoViewLeadingSpacing = screenWidth * 0.040565547158609
    
    static let infoViewBottomPadding = screenWidth * 0.0390161153519932145886344
    
    static let infoViewDividerColor = UIColor(named: "ProfilePage/StoryHighlightReelView/NoHighlightReels/dividerColor")!
    
    static let infoViewDividerHeight = 1.0/3.0
    
    static let infoViewTopSpacing = screenWidth * 0.0474978795589482612383376
    
    static let descriptionTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/StoryHighlightReelView/NoHighlightReels/descriptionColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ]
    
    static let descriptionText = NSAttributedString(string: "Keep your favorite stories on your\nprofile", attributes: descriptionTextAttributes)
    
    static let descriptionTextTopSpacing = 2.0
    
    static let fullViewIconSize = CGSize(width: 8, height: screenWidth * 0.0118744698897370653095843)
    
    static let fullViewIconTrailingSpacing = screenWidth * 0.0458015267175572519083968
    
    static let fullViewIconFillColor = UIColor(named: "ProfilePage/StoryHighlightReelView/NoHighlightReels/toggleIconFillColor")!
    
    static let fullViewIcon = UIImage(named: "ProfilePage/StoryHighlightReelView/NoHighlightReels/toggleIcon")!.withTintColor(fullViewIconFillColor).resizedTo(size: fullViewIconSize)
    
    static let fullViewIconCondensedTopSpacing = screenWidth * 0.0203562340966921119592876
    
    static let fullViewIconExpandedTopSpacing = screenWidth * 0.0856658184902459711620017
    
    static let infoCollectionViewTopSpacing = screenWidth * 0.0042408821034775233248515
    
    static let infoCollectionViewBottomSpacing = screenWidth * 0.0313825275657336726039016
}
