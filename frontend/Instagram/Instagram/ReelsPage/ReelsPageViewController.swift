//
//  ReelsPageViewController.swift
//  InstagramClone
//
//  Created by brock davis on 9/28/22.
//

import UIKit
import CoreLocation

class ReelsPageViewController: InstagramTabViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    private let reelsTitleButton = ReelPressEffectButtonView()
    private let createReelButton = ReelPressEffectButtonView()
    private let chevronButton = UIButton()
    private let collectionView: UICollectionView
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var collectionViewContentOffsetObservationToken: NSKeyValueObservation?
    private let reelCellID = "reelCell"
    private var updatingContentOffset = false
    

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(selectedTabIcon: .init(named: "ReelsIconSelected")!.withTintColor(.white).resizedTo(size: CGSize.sqaure(size: Configurations.screenWidth * 0.0565)), unselectedTabIcon: .init(named: "ReelsIconUnselected")!.resizedTo(size: CGSize.sqaure(size: Configurations.screenWidth * 0.0565)).withTintColor(.white), hasNotification: false)
        
        // Set up the collection view
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.reelCellID)
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.backgroundColor = .black
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -Configurations.reelItemLineSpacing),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: Configurations.reelItemLineSpacing)
        ])
        
        // Set up the page title button
        self.reelsTitleButton.translatesAutoresizingMaskIntoConstraints = false
        self.reelsTitleButton.effectView.animatedOpacity = 1.0
        self.reelsTitleButton.effectView.animatedScale = 0.9
        self.reelsTitleButton.button.addTarget(self, action: #selector(self.userTappedReelsPageTitleButton), for: .touchUpInside)
        self.reelsTitleButton.button.setAttributedTitle(Configurations.reelsPageTitleButtonText, for: .normal)
        self.view.addSubview(self.reelsTitleButton)
        NSLayoutConstraint.activate([
            self.reelsTitleButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.reelsPageTitleButtonLeadingSpacing),
            self.reelsTitleButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Configurations.reelsPageTitleButtonTopSpacing)
        ])
        
        // Set up the activity indicator view
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.transform = CGAffineTransformMakeScale(1.32, 1.32)
        self.activityIndicator.color = .white
        self.view.addSubview(self.activityIndicator)
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.reelsTitleButton.centerYAnchor)
        ])
        
        self.createReelButton.translatesAutoresizingMaskIntoConstraints = false
        self.createReelButton.button.addTarget(self, action: #selector(self.userTappedCreateReelButton), for: .touchUpInside)
        self.createReelButton.button.setBackgroundImage(Configurations.createButtonIcon, for: .normal)
        self.view.addSubview(self.createReelButton)
        NSLayoutConstraint.activate([
            self.createReelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Configurations.createButtonTrailingSpacing),
            self.createReelButton.centerYAnchor.constraint(equalTo: self.reelsTitleButton.centerYAnchor)
        ])
       
        
        // Set up the chevron button
        self.chevronButton.translatesAutoresizingMaskIntoConstraints = false
        self.chevronButton.addTarget(self, action: #selector(self.userTappedChevronButton), for: .touchUpInside)
        self.chevronButton.setBackgroundImage(Configurations.chevronButtonIcon, for: .normal)
        self.view.addSubview(self.chevronButton)
        NSLayoutConstraint.activate([
            self.chevronButton.trailingAnchor.constraint(equalTo: self.createReelButton.leadingAnchor, constant: -Configurations.chevronButtonTrailingSpacing),
            self.chevronButton.centerYAnchor.constraint(equalTo: self.createReelButton.centerYAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.collectionView.frame.size
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.animateReelsTitleButton(shouldHide: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("New Location: \(locations.first!.coordinate)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Observe changes to the collection view's contentOffset
        self.collectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentOffset), options: [.old, .new], context: nil)
        
        
    }
    
    private func animateReelsTitleButton(shouldHide: Bool) {
        UIView.animate(withDuration: 0.35, delay: 0) {
            self.reelsTitleButton.alpha = shouldHide ? 0 : 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.collectionView.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentOffset))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard scrollView == self.collectionView else { return }

        if self.reelsTitleButton.alpha == 1 && velocity.y > 0 {
            self.animateReelsTitleButton(shouldHide: true)
        } else if reelsTitleButton.alpha == 0 && velocity.y < 0 {
            self.animateReelsTitleButton(shouldHide: false)
        } else if scrollView.contentOffset.y < 0 {
            self.animateReelsTitleButton(shouldHide: true)
            self.activityIndicator.startAnimating()
            self.refreshCollectionItems()
        }

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard
            keyPath == #keyPath(UICollectionView.contentOffset),
            let _ = (change?[.oldKey] as? CGPoint)?.y,
            let _ = (change?[.newKey] as? CGPoint)?.y
        else { return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context) }
        
        guard !self.updatingContentOffset else { return }
    }
    
    private func refreshCollectionItems() {
        DispatchQueue.main.delay(1.5) {
            if self.activityIndicator.isAnimating {
                self.collectionView.setContentOffset(.zero, animated: true)
                self.activityIndicator.stopAnimating()
                self.animateReelsTitleButton(shouldHide: false)
            }
        }
    }
    
    private func userTappedToRefresh() {
        self.collectionView.setContentOffset(CGPoint(x: 0, y: Configurations.buttonRefreshYContentOffset), animated: true)
        self.activityIndicator.startAnimating()
        self.refreshCollectionItems()
    }
    
    @objc private func userTappedReelsPageTitleButton() {
        self.userTappedToRefresh()
    }
    
    override func userRetappedTabButton() {
        if self.collectionView.contentOffset.y == 0 {
            self.userTappedToRefresh()
        } else {
            self.collectionView.setContentOffset(.zero, animated: true)
            self.animateReelsTitleButton(shouldHide: false)
        }
    }
    
    @objc private func userTappedCreateReelButton() {
        print("user tapped create reel button")
    }
    
    @objc private func userTappedChevronButton() {
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.reelCellID, for: indexPath)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .random
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Configurations.reelItemLineSpacing),
            backgroundView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        return cell
    }

}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    // Collection View Configurations
    static let buttonRefreshYContentOffset = -screenWidth * 0.1485
    static let reelItemLineSpacing = screenWidth * 0.005
    static let reelItemSize = CGSize(width: screenWidth, height: (screenWidth * 1.965) + (reelItemLineSpacing * 2))
    
    // Reels Page title button configurations
    static let reelsPageTitleButtonLeadingSpacing = screenWidth * 0.065
    static let reelsPageTitleButtonTopSpacing = screenWidth * 0.145
    static let reelsPageTitleButtonFontSize = screenWidth * 0.0634
    static let reelsPageTitleButtonText = NSAttributedString(string: "Reels", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: reelsPageTitleButtonFontSize, weight: .bold)
    ])
    
    // Create button configurations
    static let createButtonTrailingSpacing = screenWidth * 0.043
    static let createButtonIconSize = CGSize(width: screenWidth * 0.063, height: screenWidth * 0.0591)
    static let createButtonIcon = UIImage(named: "CreateReelIcon")!.withTintColor(.white).resizedTo(size: createButtonIconSize)
    
    // Chevron button configurations
    static let chevronButtonTrailingSpacing = screenWidth * 0.0522
    static let chevronButtonIconSize = CGSize(width: screenWidth * 0.0587, height: screenWidth * 0.0313)
    static let chevronButtonIcon = UIImage(named: "ReelsPageChevron")!.resizedTo(size: chevronButtonIconSize)
    
    
}
