//
//  PostGalleryViewController.swift
//  InstagramClone
//
//  Created by brock davis on 1/22/23.
//

import UIKit

class PostGalleryViewController: GalleryViewController {
    
    private let cellID = "postCell"
    private let layout: UICollectionViewFlowLayout
    private let posts = ActiveUser.loggedIn.first!.posts
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        // Configure layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = Configurations.itemSize
        layout.minimumInteritemSpacing = Configurations.interColumnSpacing
        layout.minimumLineSpacing = Configurations.interRowSpacing
        self.layout = layout
        
        super.init(layout: layout)
        
        self.collectionView.register(ProfilePagePostView.self, forCellWithReuseIdentifier: self.cellID)
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(self.refreshTriggered), for: .primaryActionTriggered)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    @objc private func refreshTriggered() {
        DispatchQueue.main.delay(1.5) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postView = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! ProfilePagePostView
        postView.post = self.posts[indexPath.item]
        return postView
    }
    
    override var profileContentHeight: CGFloat {
        didSet {
            self.layout.sectionInset = UIEdgeInsets(top: profileContentHeight + Configurations.interRowSpacing, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item selected")
    }

}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let itemSize = CGSize.sqaure(size: (screenWidth / 3) - ((interColumnSpacing * 2) / 3))
    static let interColumnSpacing: CGFloat = 1
    static let interRowSpacing = interColumnSpacing
}
