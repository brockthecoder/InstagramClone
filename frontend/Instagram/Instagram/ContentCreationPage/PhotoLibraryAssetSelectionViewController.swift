//
//  PhotoLibraryAssetSelectionViewController.swift
//  PhotoTestingApp
//
//  Created by brock davis on 10/11/22.
//

import UIKit
import Photos

class PhotoLibraryAssetSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, AlbumPickerViewControllerDelegate {
    
    // Photo Library unauthoried
    private let photoLibraryUseDescriptionLabel = UILabel()
    private let enablePhotosAccessButton = UIButton()
    
    // The header view and its subviewsz
    let headerView = UIView()
    let albumSelectionButton = UIButton()
    
    // The underlying collection view
    private var collectionView: UICollectionView!

    private let imageAssetCellId = "imageAssetCell"
    private var currentAssetCollection: PHAssetCollection? {
        didSet {
            if let currentAssetCollection = self.currentAssetCollection {
                // Update the album selection button
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                let albumTitle = (currentAssetCollection.localizedTitle == nil) ? "Album" : currentAssetCollection.localizedTitle!
                let attributedAlbumTitle = NSAttributedString(string: albumTitle, attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: self.viewWidth / 20.7, weight: .semibold)
                ])
                let buttonSize = CGSize(width: self.viewWidth * 0.415, height: self.viewWidth * 0.129)
                self.albumSelectionButton.setBackgroundImage(Configurations.albumSelectionButtonBackground(withTitle: attributedAlbumTitle, size: buttonSize), for: .normal)
                self.currentAssets.removeAll()
                self.cachingImageManger.stopCachingImagesForAllAssets()
                for request in self.fetchRequests.values {
                    self.cachingImageManger.cancelImageRequest(request)
                }
                self.fetchRequests.removeAll()
                self.requestsToCancel.removeAll()
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = self.numberOfItemsOnScreen * 3
                let limitedAssetsFetchResults = PHAsset.fetchAssets(in: currentAssetCollection, options: fetchOptions)
                self.currentAssets = limitedAssetsFetchResults.objects(at: IndexSet(0..<limitedAssetsFetchResults.count))
                let thumbnailToFetch = self.currentAssets.first!
                let thumbnailRequestOptions = PHImageRequestOptions()
                if thumbnailToFetch.pixelWidth != thumbnailToFetch.pixelHeight {
                    let smallerDimension = min(thumbnailToFetch.pixelWidth, thumbnailToFetch.pixelHeight)
                    let widthDifference = thumbnailToFetch.pixelWidth - smallerDimension
                    let heightDifference = thumbnailToFetch.pixelHeight - smallerDimension
                    let cropOrigin = CGPoint(x: (widthDifference / thumbnailToFetch.pixelWidth) / 2, y: (heightDifference / thumbnailToFetch.pixelHeight) / 2)
                    let cropSize = CGSize(width: (widthDifference / thumbnailToFetch.pixelWidth) / 2, height: (heightDifference / thumbnailToFetch.pixelHeight) / 2)
                    thumbnailRequestOptions.normalizedCropRect = CGRect(origin: cropOrigin, size: cropSize)
                    thumbnailRequestOptions.resizeMode = .exact
                }
                thumbnailRequestOptions.deliveryMode = .fastFormat
                self.cachingImageManger.requestImage(for: thumbnailToFetch, targetSize: CGSize.sqaure(size: 25), contentMode: .aspectFill, options: thumbnailRequestOptions) { image, _ in
                    if let image = image {
                        self.currentThumbnail = image
                    }
                }
                self.collectionView.reloadData()
                // Check if there are more image to beyond the initial fetch
                // If so - fetch asynchronously
                if self.currentAssetCollectionCount > self.currentAssets.count {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        let fullAssetFetchResult = PHAsset.fetchAssets(in: currentAssetCollection, options: fetchOptions)
                        DispatchQueue.main.async {
                            self.currentAssets = fullAssetFetchResult.objects(at: IndexSet(0..<fullAssetFetchResult.count))
                            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    private var currentAssetCollectionCount: Int = 0
    private var currentAssets: [PHAsset] = []
    private var fetchRequests: [IndexPath: PHImageRequestID] = [:]
    private var requestsToCancel: [IndexPath: PHImageRequestID] = [:]
    
    
    private var albumPicker: AlbumPickerViewController!
    private var cachingImageManger: PHCachingImageManager!

    var useType: InstagramPhotoAssetUseType {
        didSet {
            self.collectionView.setCollectionViewLayout(self.configureLayout(), animated: false)
        }
    }
    private var numberOfItemsOnScreen: Int {
        let rowCountOnScreen = ceil(self.viewHeight / self.itemHeight)
        return Int(rowCountOnScreen) * Int(self.itemCount)
    }
    
    private var imageAssetTargetSize: CGSize {
        return CGSize(width: self.itemWidth, height: self.itemHeight).applying(CGAffineTransformMakeScale(UIScreen.main.scale, UIScreen.main.scale))
    }
    
    private var viewWidth: CGFloat {
        return (self.view.bounds.width == 0) ? UIScreen.main.bounds.width : self.view.bounds.width
    }
    
    private var viewHeight: CGFloat {
        return (self.view.bounds.height == 0) ? UIScreen.main.bounds.height : self.view.bounds.height
    }
    
    private var interItemSpacing: CGFloat {
        return (self.useType == .post) ? viewWidth / 80 : viewWidth / 200
    }
    
    private var spacingCount: CGFloat {
        return (self.useType == .post) ? 3 : 2
    }
    
    private var itemCount: CGFloat {
        return (self.useType == .post) ? 4 : 3
    }
    
    private var itemWidth: CGFloat {
        return (viewWidth - (interItemSpacing * spacingCount)) / itemCount
    }
    
    private var itemHeight: CGFloat {
        return (self.useType == .post) ? itemWidth : (self.itemWidth * (16/9))
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc dynamic var currentThumbnail: UIImage?
    
    private var photoLibraryAccessGranted: Bool = false {
        didSet {
            if photoLibraryAccessGranted {
                print("photo library access granted")
                self.photoLibraryUseDescriptionLabel.isHidden = true
                self.enablePhotosAccessButton.isHidden = true
                
                self.albumPicker = AlbumPickerViewController()
                self.cachingImageManger = PHCachingImageManager()
                
                defer {
                    self.currentAssetCollectionCount = self.albumPicker.selectedAssetCollectionAssetCount
                    self.currentAssetCollection = self.albumPicker.selectedAssetCollection!
                }
                
                self.headerView.translatesAutoresizingMaskIntoConstraints = false
                self.headerView.backgroundColor = .black
                self.view.addSubview(self.headerView)
                NSLayoutConstraint.activate([
                    self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    self.headerView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4)
                ])
                
                self.albumSelectionButton.translatesAutoresizingMaskIntoConstraints = false
                self.albumSelectionButton.addTarget(self, action: #selector(self.userTappedAlbumSelectButton), for: .touchUpInside)
                self.headerView.addSubview(self.albumSelectionButton)
                NSLayoutConstraint.activate([
                    self.albumSelectionButton.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
                    self.albumSelectionButton.bottomAnchor.constraint(equalTo: self.headerView.bottomAnchor)
                ])
                
                self.albumPicker.delegate = self
                self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.collectionView.prefetchDataSource = self
                self.collectionView.translatesAutoresizingMaskIntoConstraints = false
                self.collectionView.backgroundColor = .black
                self.view.addSubview(self.collectionView)
                NSLayoutConstraint.activate([
                    self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    self.collectionView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
                    self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
                
                self.collectionView.register(PhotoLibraryAssetSelectionViewCell.self, forCellWithReuseIdentifier: self.imageAssetCellId)
            }
        }
    }

    init(useType: InstagramPhotoAssetUseType = .post) {
        self.useType = useType
        super.init(nibName: nil, bundle: nil)
        
        let screenWidth = UIScreen.main.bounds.width
        
        // Set up the photo library usage description label
        self.photoLibraryUseDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        self.photoLibraryUseDescriptionLabel.attributedText = NSAttributedString(string: "Let Instagram access Photos to add recent\n photos and videos to your story", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: screenWidth * 0.04465, weight: .regular),
            .paragraphStyle: paragraphStyle
        ])
        self.photoLibraryUseDescriptionLabel.numberOfLines = 2
        self.view.addSubview(self.photoLibraryUseDescriptionLabel)
        NSLayoutConstraint.activate([
            self.photoLibraryUseDescriptionLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: screenWidth * 0.035),
            self.photoLibraryUseDescriptionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.photoLibraryUseDescriptionLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
        
        // Set up the photo library auth enable button
        self.enablePhotosAccessButton.translatesAutoresizingMaskIntoConstraints = false
        self.enablePhotosAccessButton.setAttributedTitle(NSAttributedString(string: "Enable photos access", attributes: [
            .foregroundColor: UIColor(named: "ContentCreationPage/EnablePhotosAccesTextColor")!,
            .font: UIFont.systemFont(ofSize: screenWidth * 0.0475, weight: .regular)
        ]), for: .normal)
        self.enablePhotosAccessButton.addTarget(self, action: #selector(self.userTappedEnablePhotosAccessButton), for: .touchUpInside)
        self.view.addSubview(self.enablePhotosAccessButton)
        NSLayoutConstraint.activate([
            self.enablePhotosAccessButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.enablePhotosAccessButton.topAnchor.constraint(equalTo: self.photoLibraryUseDescriptionLabel.bottomAnchor, constant: screenWidth * 0.135)
        ])
        
        defer {
            self.photoLibraryAccessGranted = PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.photoLibraryAccessGranted {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { authStatus in
                DispatchQueue.main.async {
                    self.photoLibraryAccessGranted = authStatus == .authorized
                }
            }
        }
    }
    
    @objc private func userTappedEnablePhotosAccessButton() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(self.itemWidth), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.itemHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(self.itemCount))
        group.interItemSpacing = .fixed(self.interItemSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = self.interItemSpacing
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func albumPickerViewControllerDidCancel(_ viewController: AlbumPickerViewController) {
        self.dismiss(animated: true)
    }
    
    func albumPickerViewControllerDidPickAlbum(_ viewController: AlbumPickerViewController) {
        self.dismiss(animated: true)
        if let assetSelection = viewController.selectedAssetCollection, assetSelection != self.currentAssetCollection {
            self.currentAssetCollectionCount = viewController.selectedAssetCollectionAssetCount
            self.currentAssetCollection = assetSelection
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var assetsToPrefetch: [PHAsset] = []
        for indexPath in indexPaths {
            assetsToPrefetch.append(self.currentAssets[indexPath.item])
        }
        self.cachingImageManger.startCachingImages(for: assetsToPrefetch, targetSize: self.imageAssetTargetSize, contentMode: .aspectFill, options: nil)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let request = self.fetchRequests[indexPath] {
                self.requestsToCancel[indexPath] = request
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imageRequest = self.fetchRequests[indexPath] {
            self.requestsToCancel[indexPath] = imageRequest
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.requestsToCancel[indexPath] = nil
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var assetsToCancelCachingFor: [PHAsset] = []
        let indexPathRequestsToCleanUp = self.requestsToCancel.keys.filter { cancellationIndexPath in
            return (cancellationIndexPath.item <  (indexPath.item - (self.numberOfItemsOnScreen * 3))) || (cancellationIndexPath.item > (indexPath.item + (self.numberOfItemsOnScreen * 3)))
        }
        
        indexPathRequestsToCleanUp.forEach {
            let requestId = self.requestsToCancel[$0]!
            self.cachingImageManger.cancelImageRequest(requestId)
            assetsToCancelCachingFor.append(self.currentAssets[$0.item])
            self.requestsToCancel.removeValue(forKey: $0)
            self.fetchRequests.removeValue(forKey: $0)
        }
        if !assetsToCancelCachingFor.isEmpty {
            self.cachingImageManger.stopCachingImages(for: assetsToCancelCachingFor, targetSize: self.imageAssetTargetSize, contentMode: .aspectFill, options: nil)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.imageAssetCellId, for: indexPath) as! PhotoLibraryAssetSelectionViewCell
        let asset = self.currentAssets[indexPath.item]
        
        
        cell.currentAssetIdentifier = asset.localIdentifier
        
        let requestOpts = PHImageRequestOptions()
        requestOpts.deliveryMode = .opportunistic
        requestOpts.isNetworkAccessAllowed = true
        requestOpts.resizeMode = .exact
        let imageCropRect: CGRect
        if CGFloat(asset.pixelHeight) > (CGFloat(asset.pixelWidth) * (16.0/9.0)) {
            let updatedPixelHeight = CGFloat(asset.pixelWidth) * (16.0/9.0)
            let proportionalDifference = 1 - (updatedPixelHeight / CGFloat(asset.pixelHeight))
            imageCropRect = CGRect(x: 0, y: proportionalDifference / 2.0, width: 1, height: 1 - (proportionalDifference))
        }
        else {
            let updatedPixelWidth = CGFloat(asset.pixelHeight) / (16.0/9.0)
            let proporationalDifference = 1 - (updatedPixelWidth / CGFloat(asset.pixelWidth))
            imageCropRect = CGRect(x: proporationalDifference / 2.0, y: 0, width: 1 - proporationalDifference, height: 1)
        }
        requestOpts.normalizedCropRect = imageCropRect
        let imageRequest = self.cachingImageManger.requestImage(for: asset, targetSize: self.imageAssetTargetSize, contentMode: .aspectFill, options: requestOpts) { img, _ in
            if cell.currentAssetIdentifier == asset.localIdentifier {
                if let img = img {
                    cell.image = img
                }
            }
        }
        self.fetchRequests[indexPath] = imageRequest
        return cell
    }

    @objc private func userTappedAlbumSelectButton() {
        self.present(self.albumPicker, animated: true)
    }
}

public enum InstagramPhotoAssetUseType {
    case story
    case post
}

private struct Configurations {
    public static func albumSelectionButtonBackground(withTitle title: NSAttributedString, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            let chevronWidth = size.height * 0.25
            let chevronSize = CGSize(width: chevronWidth, height: chevronWidth / 1.8)
            let chevronLeadingInset = size.height * 0.073
            let textSize = title.size()
            let textInset = size.height * 0.218
            var textRect = CGRect(x: textInset, y: textSize.height / 2, width: textSize.width, height: textSize.height)
            if (textRect.maxX + chevronWidth + chevronLeadingInset) > size.width {
                let overflowWidth = size.width - (textRect.maxX + chevronWidth + chevronLeadingInset)
                textRect = CGRect(x: textRect.origin.x, y: textRect.origin.y, width: textRect.width - overflowWidth, height: textRect.height)
            }
            title.draw(in: textRect)
            let chevronRect = CGRect(x: textRect.maxX + chevronLeadingInset, y: textRect.midY - (chevronSize.height / 2), width: chevronSize.width, height: chevronSize.height)
            UIImage(systemName: "chevron.down")!.withTintColor(.white).draw(in: chevronRect)
        }
    }
}
