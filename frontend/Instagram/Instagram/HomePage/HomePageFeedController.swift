//
//  HomePageFeedController.swift
//  InstagramClone
//
//  Created by brock davis on 10/22/22.
//

import UIKit

class HomePageFeedController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let storiesVC: StoriesViewController
    private let collectionView: UICollectionView
    var contentOffset: CGPoint {
        self.collectionView.contentOffset
    }
    private let storyCellId = "StoryCell"
    private let postCellId = "PostCell"
    private let dividerId = "PostFeedDivider"
    var delegate: HomePageFeedControllerDelegate?
    private let posts = Array<FeedPost>(ActiveUser.loggedIn.first!.feed.posts.reversed())
    private var reelPlayers = [ReelPostPlayerView: CGRect]() {
        didSet {
            self.updateActiveReelPlayers()
        }
    }
    private var contentOffsetObservation: NSKeyValueObservation!
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(storiesViewController: StoriesViewController) {
        let viewWidth = UIScreen.main.bounds.width
        self.storiesVC = storiesViewController
        let layout = UICollectionViewCompositionalLayout { index, env in
            if index == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(107))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                let dividerViewSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1.0 / 3.0))
                let divider = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: dividerViewSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                section.boundarySupplementaryItems = [divider]
                return section
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(viewWidth * 2))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(viewWidth * 2))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                return NSCollectionLayoutSection(group: group)
            }
        }
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.storyCellId)
        self.collectionView.register(PostView.self, forCellWithReuseIdentifier: self.postCellId)
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: self.dividerId)
        super.init(nibName: nil, bundle: nil)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(self.refreshControlTriggered), for: .primaryActionTriggered)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        self.collectionView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.appEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appMovingToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.contentOffsetObservation = self.collectionView.observe(\.contentOffset) { _, _ in
            self.updateActiveReelPlayers()
        }
    }
    
    private func updateActiveReelPlayers() {
        var foundTheOne = false
        for (reelPlayer, playerFrame) in self.reelPlayers.sorted(by: { $0.value.minY < $1.value.minY }) {
            if self.collectionView.contentOffset.y - (playerFrame.maxY * 0.75) < 0, !foundTheOne {
                foundTheOne = true
                guard !reelPlayer.playing else { break }
                reelPlayer.startPlaying()
            } else {
                guard reelPlayer.playing else { break }
                reelPlayer.stopPlaying()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? 1 : self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return self.collectionView.dequeueReusableCell(withReuseIdentifier: self.storyCellId, for: indexPath)
        } else {
            let postView = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.postCellId, for: indexPath) as! PostView
            postView.post = self.posts[indexPath.item]
            return postView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let divider = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: self.dividerId, for: indexPath)
        divider.backgroundColor = UIColor(named: "HomePage/StoriesCollectionBottomDividerColor")!
        return divider
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.addChild(self.storiesVC)
            let storiesView = self.storiesVC.view!
            storiesView.translatesAutoresizingMaskIntoConstraints = false
            storiesView.tag = 999
            cell.contentView.addSubview(storiesView)
            NSLayoutConstraint.activate([
                storiesView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                storiesView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                storiesView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                storiesView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            self.storiesVC.didMove(toParent: self)
        } else if indexPath.section == 1 {
            let cell = cell as! PostView
            cell.willDisplay(in: self.collectionView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0, let storiesView = cell.viewWithTag(999) {
            self.storiesVC.willMove(toParent: nil)
            storiesView.removeFromSuperview()
            self.storiesVC.removeFromParent()
        } else if indexPath.section == 1 {
            let cell = cell as! PostView
            cell.didEndDisplaying(in: self.collectionView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.collectionView.contentOffset.y > 0 {
            self.delegate?.homePageFeedViewDidScroll(self, newContentOffset: scrollView.contentOffset)
        }
    }
    
    func addReelPlayerToQueue(_ reelPlayer: ReelPostPlayerView, from postView: PostView) {
        if self.reelPlayers[reelPlayer] == nil {
            self.reelPlayers[reelPlayer] = self.collectionView.convert(reelPlayer.frame, from: postView)
        }
    }
    
    func removeReelPlayerFromQueue(_ reelPlayer: ReelPostPlayerView) {
        self.reelPlayers[reelPlayer] = nil
        reelPlayer.stopPlaying()
    }
    
    @objc private func refreshControlTriggered() {
        self.delegate?.homePageFeedControllerDidRefresh(self)
        DispatchQueue.main.delay(1) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        for postView in self.collectionView.visibleCells.compactMap({ $0 as? PostView }) {
            postView.didEndDisplaying(in: self.collectionView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for postView in self.collectionView.visibleCells.compactMap({ $0 as? PostView }) {
            postView.willDisplay(in: self.collectionView)
        }
    }
    
    @objc private func appEnteredBackground() {
        if self.view.window != nil {
            for postView in self.collectionView.visibleCells.compactMap({ $0 as? PostView }) {
                postView.didEndDisplaying(in: self.collectionView)
            }
        }
    }
    
    @objc private func appMovingToForeground() {
        if self.view.window != nil {
            for postView in self.collectionView.visibleCells.compactMap({ $0 as? PostView }) {
                postView.willDisplay(in: self.collectionView)
            }
        }
    }

}

protocol HomePageFeedControllerDelegate {
    
    func homePageFeedControllerDidRefresh(_ viewController: HomePageFeedController)
    
    func homePageFeedViewDidScroll(_ viewController: HomePageFeedController, newContentOffset contentOffset : CGPoint)
}
