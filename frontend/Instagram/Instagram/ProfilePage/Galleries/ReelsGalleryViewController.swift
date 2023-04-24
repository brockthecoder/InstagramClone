//
//  ReelsGalleryViewController.swift
//  InstagramClone
//
//  Created by brock davis on 1/22/23.
//

import UIKit

class ReelsGalleryViewController: GalleryViewController {

    private let layout: UICollectionViewFlowLayout
    private let cellID = "reelCell"
    private let reels = ActiveUser.loggedIn.first!.reels.sorted { $0.takenAt > $1.takenAt }.sorted { reelA, reelB in reelA.isPinned }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = Configurations.itemSize
        layout.minimumInteritemSpacing = Configurations.interColumnSpacing
        layout.minimumLineSpacing = Configurations.interRowSpacing
        self.layout = layout
        
        super.init(layout: self.layout)
        self.collectionView.register(ProfilePageReelView.self, forCellWithReuseIdentifier: self.cellID)
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(self.refreshTriggered), for: .primaryActionTriggered)
    }
    
    override var profileContentHeight: CGFloat {
        didSet {
            self.layout.sectionInset = UIEdgeInsets(top: profileContentHeight + Configurations.interRowSpacing, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc private func refreshTriggered() {
        DispatchQueue.main.delay(1.5) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reelView = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! ProfilePageReelView
        reelView.reel = self.reels[indexPath.item]
        return reelView
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let interColumnSpacing: CGFloat = 1
    static let interRowSpacing = interColumnSpacing
    static let itemSize = CGSize(width: (screenWidth / 3) - ((interColumnSpacing * 2) / 3), height: ((screenWidth / 3) - ((interColumnSpacing * 2) / 3)) / 0.5625)
}
