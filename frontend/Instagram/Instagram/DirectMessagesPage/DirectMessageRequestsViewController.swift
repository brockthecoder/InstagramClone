//
//  MessageRequestsViewController.swift
//  InstagramClone
//
//  Created by brock davis on 11/4/22.
//

import UIKit

class DirectMessageRequestsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Page Header
    private let headerView = UIView()
    private let backButton = UIButton()
    private let pageTitleLabel = UILabel()
    private let editButton = UIButton()
    private let headerDividerView = UIView()
    
    // Page Footer
    private let footerView = UIView()
    private let footerDividerView = UIView()
    private let deleteAllButton = UIButton()
    
    // Collection view components
    private let collectionView: UICollectionView
    private let requestCellId = "requestCell"
    private let hiddenRequestsCellId = "hiddenRequestsCell"
    private let headerId = "collectionHeader"
    private var chatRequests: [Chat] = ActiveUser.loggedIn.first!.chats.filter { $0.grouping == .requests }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        
        // Set up the collection view
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.183))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.3))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.register(DirectMessageRequestCollectionViewCell.self, forCellWithReuseIdentifier: self.requestCellId)
        self.collectionView.register(DirectMessagesRequestCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerId)
        self.collectionView.register(DirectMessageHiddenRequestsCollectionViewCell.self, forCellWithReuseIdentifier: self.hiddenRequestsCellId)
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.refreshControl = UIRefreshControl()
        
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.refreshControl?.addTarget(self, action: #selector(self.refreshControlTriggered), for: .primaryActionTriggered)
        
        // Set up the page header
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.backgroundColor = .black
        self.view.addSubview(self.headerView)
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: Configurations.headerHeight)
        ])
        
        // Set up the page header divider view
        self.headerDividerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerDividerView.backgroundColor = Configurations.headerDividerBackgroundColor
        self.headerView.addSubview(self.headerDividerView)
        NSLayoutConstraint.activate([
            self.headerDividerView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.headerDividerView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.headerDividerView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.headerDividerView.heightAnchor.constraint(equalToConstant: Configurations.headerDividerHeight)
        ])
        
        // Set up the back button
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.setBackgroundImage(Configurations.backButtonChevron, for: .normal)
        self.backButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
        self.headerView.addSubview(self.backButton)
        NSLayoutConstraint.activate([
            self.backButton.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: Configurations.backButtonLeadingSpacing),
            self.backButton.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: -Configurations.backButtonBottomSpacing)
        ])
        
        // Set up the page title
        self.pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.pageTitleLabel.attributedText = Configurations.pageTitleText
        self.headerView.addSubview(self.pageTitleLabel)
        NSLayoutConstraint.activate([
            self.pageTitleLabel.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor),
            self.pageTitleLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor)
        ])
        
        // Set up the edit button
        self.editButton.translatesAutoresizingMaskIntoConstraints = false
        self.editButton.setAttributedTitle(Configurations.editButtonText, for: .normal)
        self.editButton.addTarget(self, action: #selector(self.editButtonTapped), for: .touchUpInside)
        self.headerView.addSubview(self.editButton)
        NSLayoutConstraint.activate([
            self.editButton.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor),
            self.editButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -Configurations.editButtonTrailingSpacing)
        ])
        
        // Set up the page footer
        self.footerView.translatesAutoresizingMaskIntoConstraints = false
        self.footerView.backgroundColor = .black
        self.view.addSubview(self.footerView)
        NSLayoutConstraint.activate([
            self.footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.footerView.heightAnchor.constraint(equalToConstant: Configurations.footerHeight)
        ])
        
        // Set up the page footer divider
        self.footerDividerView.translatesAutoresizingMaskIntoConstraints = false
        self.footerDividerView.backgroundColor = Configurations.footerDividerBackgroundColor
        self.footerView.addSubview(self.footerDividerView)
        NSLayoutConstraint.activate([
            self.footerDividerView.leadingAnchor.constraint(equalTo: self.footerView.leadingAnchor),
            self.footerDividerView.trailingAnchor.constraint(equalTo: self.footerView.trailingAnchor),
            self.footerDividerView.bottomAnchor.constraint(equalTo: self.footerView.topAnchor),
            self.footerDividerView.heightAnchor.constraint(equalToConstant: Configurations.footerDividerHeight)
        ])
        
        // Set up the delete all button
        self.deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteAllButton.setAttributedTitle(Configurations.deleteAllButtonText, for: .normal)
        self.deleteAllButton.addTarget(self, action: #selector(self.deleteAllButtonTapped), for: .touchUpInside)
        self.footerView.addSubview(self.deleteAllButton)
        NSLayoutConstraint.activate([
            self.deleteAllButton.centerXAnchor.constraint(equalTo: self.footerView.centerXAnchor),
            self.deleteAllButton.topAnchor.constraint(equalTo: self.footerView.topAnchor, constant: Configurations.deleteAllButtonTopSpacing)
        ])
        
        // Put the collection view into the view hierarchy
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(self.collectionView, belowSubview: self.headerView)
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.headerDividerView.bottomAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.footerDividerView.topAnchor)
        ])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.chatRequests.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.item != self.collectionView.numberOfItems(inSection: 0) - 1 else {
            let hiddenRequestsView = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.hiddenRequestsCellId, for: indexPath) as! DirectMessageHiddenRequestsCollectionViewCell
            hiddenRequestsView.hiddenRequestsCount = ActiveUser.loggedIn.first!.chats.filter({ $0.grouping == .hiddenRequests}).count
            return hiddenRequestsView
        }
        
        let requestView = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.requestCellId, for: indexPath) as! DirectMessageRequestCollectionViewCell
        requestView.chatRequest = self.chatRequests[indexPath.item]
        return requestView
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerId, for: indexPath)
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func editButtonTapped() {
        
    }
    
    @objc private func deleteAllButtonTapped() {
        
    }
    
    @objc private func refreshControlTriggered() {
        DispatchQueue.main.delay(2) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}

private struct Configurations {
    
    static let viewWidth = UIScreen.main.bounds.width
    static let headerHeight = viewWidth * 0.24678
    static let headerDividerBackgroundColor = UIColor(named: "DMRequestsPageHeaderDividerColor")!
    static let headerDividerHeight = viewWidth * 0.001
    
    // Back Button Configurations
    static let backButtonSize = CGSize(width: viewWidth * 0.045, height: viewWidth * 0.062)
    static let backButtonLeadingSpacing = viewWidth * 0.02
    static let backButtonBottomSpacing = viewWidth * 0.0257
    static let backButtonChevron = UIImage(systemName: "chevron.backward")?.withTintColor(.white).resizedTo(size: backButtonSize)

    // Page title Configurations
    static let pageTitleText = NSAttributedString(string: "Message requests", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: viewWidth * 0.048, weight: .semibold)
    ])
    
    // Edit button Configurations
    static let editButtonTrailingSpacing = viewWidth * 0.0283
    static let editButtonText = NSAttributedString(string: "Edit", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: viewWidth * 0.0478, weight: .regular)
    ])
    
    // Footer Configurations
    static let footerHeight = viewWidth * 0.2
    static let footerDividerBackgroundColor = UIColor(named: "DMRequestsPageFooterDividerColor")!
    static let footerDividerHeight = viewWidth * 0.001
    
    // Delete all button configurations
    static let deleteAllButtonTopSpacing = viewWidth * 0.0187
    static let deleteAllButtonText = NSAttributedString(string: "Delete all", attributes: [
        .foregroundColor: UIColor(named: "DeleteAllTextColor")!,
        .font: UIFont.systemFont(ofSize: viewWidth * 0.046, weight: .medium)
    ])
    
}
