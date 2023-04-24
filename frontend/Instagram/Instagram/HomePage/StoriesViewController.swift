//
//  StoriesViewController.swift
//  InstagramClone
//
//  Created by brock davis on 9/29/22.
//

import UIKit

class StoriesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellID = "STORY_CELL"
    private let createStoryViewTag = 333
    private let pfpViewTag = 777
    private let usernameLabelTag = 888
    private let activeUser = ActiveUser.loggedIn.first!
    private let stories = ActiveUser.loggedIn.first!.feed.stories

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(Configurations.itemWidth), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Configurations.interItemSpacing
        section.contentInsets = Configurations.sectionInset
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout(section: section))
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = .black
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stories.count + 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath)
        
        if cell.contentView.viewWithTag(self.usernameLabelTag) == nil {
            let usernameLabel = UILabel()
            usernameLabel.lineBreakMode = .byTruncatingTail
            usernameLabel.textAlignment = .center
            usernameLabel.tag = self.usernameLabelTag
            cell.contentView.addSubview(usernameLabel) {
                $0.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    $0.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                    $0.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
            }
        }
        
        // User's story view
        if indexPath.item == 0 {
            
            // Set label text
            if let usernameLabel = cell.contentView.viewWithTag(self.usernameLabelTag) as? UILabel {
                usernameLabel.attributedText = Configurations.yourStoryText
            }
            
            if activeUser.hasPublicStory {
                cell.contentView.viewWithTag(self.createStoryViewTag)?.removeFromSuperview()
                
                
                if cell.contentView.viewWithTag(self.pfpViewTag) == nil {
                    let pfpView = ProfilePictureView(outlineWidth: 7.7 / 3.0)
                    pfpView.tag = self.pfpViewTag
                    cell.contentView.addSubview(pfpView) {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                            $0.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                            $0.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                            $0.heightAnchor.constraint(equalTo: cell.contentView.widthAnchor)
                        ])
                    }
                }
                
                let pfpView = cell.contentView.viewWithTag(self.pfpViewTag) as! ProfilePictureView
                pfpView.profilePicture = activeUser.profilePicture
                pfpView.storyStatus = .unseen
                
                return cell
            } else {
                cell.contentView.viewWithTag(self.pfpViewTag)?.removeFromSuperview()
                if cell.contentView.viewWithTag(self.createStoryViewTag) == nil {
                    let createStoryView = CreateStoryView()
                    createStoryView.tag = self.createStoryViewTag
                    cell.contentView.addSubview(createStoryView) {
                        $0.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                            $0.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                            $0.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                            $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
                        ])
                    }
                }
                
                let createStoryView = cell.contentView.viewWithTag(self.createStoryViewTag) as! CreateStoryView
                createStoryView.profilePicture = activeUser.profilePicture
                return cell
            }
        }
        // Non-user story
        else {
            
            let story = self.stories[indexPath.item - 1]
            
            // Set label text
            if let usernameLabel = cell.contentView.viewWithTag(self.usernameLabelTag) as? UILabel {
                usernameLabel.attributedText = NSAttributedString(string: story.username, attributes: Configurations.usernameTextAttributes)
            }
            
            cell.contentView.viewWithTag(self.createStoryViewTag)?.removeFromSuperview()
            
            if cell.contentView.viewWithTag(self.pfpViewTag) == nil {
                let pfpView = ProfilePictureView(outlineWidth: 7.7 / 3.0)
                pfpView.tag = self.pfpViewTag
                cell.contentView.addSubview(pfpView) {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        $0.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 2),
                        $0.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                        $0.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -2),
                        $0.heightAnchor.constraint(equalTo: $0.widthAnchor)
                    ])
                }
            }
            
            let pfpView = cell.contentView.viewWithTag(self.pfpViewTag) as! ProfilePictureView
            pfpView.profilePicture = story.profilePicture
            pfpView.storyStatus = .unseen
            
            return cell
           
        }
    }
}

private struct Configurations {
    
    static let itemWidth = 78.0
    
    static let sectionInset = NSDirectionalEdgeInsets(top: 3, leading: 19.0 / 3.0, bottom: 31.0 / 3.0, trailing: 10)
    
    static let interItemSpacing = 9.0
    
    static let yourStoryText = NSAttributedString(string: "Your story", attributes: [
        .foregroundColor: UIColor(named: "Stories/Create/textColor")!,
        .font: UIFont.systemFont(ofSize: 11.5, weight: .regular)
    ])
    
    static let usernameTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "Stories/usernameTextColor")!,
        .font: UIFont.systemFont(ofSize: 11.5, weight: .regular)
    ]
}
