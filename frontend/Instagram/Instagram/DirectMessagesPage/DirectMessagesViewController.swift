//
//  DirectMessagesViewController.swift
//  InstagramClone
//
//  Created by brock davis on 10/19/22.
//

import UIKit

class DirectMessagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DirectMessagesHeaderViewDelegate, UIGestureRecognizerDelegate {
    
    private let cellID = "DirectMessageCell"
    private let headerID = "DirectMessagesHeader"

    private let collectionView: UICollectionView
    private lazy var dmRequestsVC = DirectMessageRequestsViewController()
    private let tapToDismissSearchRecognizer: UITapGestureRecognizer
    private let primaryChats = ActiveUser.loggedIn.first!.chats.filter { $0.grouping == .primary }
    private let generalChats = ActiveUser.loggedIn.first!.chats.filter { $0.grouping == .general }
    var currentGrouping: MessageGrouping = .primary
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        self.tapToDismissSearchRecognizer = UITapGestureRecognizer()
        self.tapToDismissSearchRecognizer.numberOfTapsRequired = 1
        self.tapToDismissSearchRecognizer.numberOfTouchesRequired = 1
        
        // Create and configure the collection view
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.185))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.2693))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(section: section)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.register(DirectMessageCollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
        self.collectionView.register(DirectMessagesCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerID)
        super.init(nibName: nil, bundle: nil)
        self.tapToDismissSearchRecognizer.delegate = self
        self.tapToDismissSearchRecognizer.addTarget(self, action: #selector(self.userTappedToDismissSearch))
        self.collectionView.backgroundColor = .black
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.indicatorStyle = .white
        self.collectionView.showsVerticalScrollIndicator = true
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(self.refreshTriggered), for: .primaryActionTriggered)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
    @objc private func refreshTriggered() {
        DispatchQueue.main.delay(1) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.currentGrouping == .primary) ? self.primaryChats.count : self.generalChats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! DirectMessageCollectionViewCell
        cell.chat = (self.currentGrouping == .primary) ? self.primaryChats[indexPath.item] : self.generalChats[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerID, for: indexPath) as! DirectMessagesCollectionHeaderView
        header.delegate = self
        return header
    }
    
    func headerView(_ view: DirectMessagesCollectionHeaderView, didStartSearchWith textField: UITextField) {
        self.collectionView.addGestureRecognizer(self.tapToDismissSearchRecognizer)
    }
    
    func headerView(_ view: DirectMessagesCollectionHeaderView, didEndSearchWith textField: UITextField) {
        self.collectionView.removeGestureRecognizer(self.tapToDismissSearchRecognizer)
    }
    
    func headerView(_ view: DirectMessagesCollectionHeaderView, didSelectMessageGrouping grouping: MessageGrouping) {
        self.currentGrouping = grouping
        self.collectionView.reloadData()
    }
    
    func headerViewSelectedRequestsTab(_ view: DirectMessagesCollectionHeaderView) {
        self.navigationController?.pushViewController(self.dmRequestsVC, animated: true)
    }
    
    @objc private func userTappedToDismissSearch() {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
