//
//  AssetCollectionPickerViewController.swift
//  PhotoTestingApp
//
//  Created by brock davis on 10/11/22.
//

import UIKit
import Photos

class AlbumPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Header view contents
    private let headerView = UIView()
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let dividerView = UIView()
    
    // Contents to populate collection view with
    private var keySmartAlbums: [PHAssetCollection] = []
    private var userAlbums: [PHAssetCollection] = []
    private var otherSmartAlbums: [PHAssetCollection] = []
    private var thumbnailMap: [PHAssetCollection:UIImage] = [:]
    private var assetCounts: [PHAssetCollection:Int] = [:]
    
    // Cell IDs
    private let albumCellId = "albumCellId"
    private let sectionHeaderId = "albumSectionHeaderId"
    
    // Underlying Collection View
    private var collectionView: UICollectionView!
    
    // Public variable interface
    var delegate: AlbumPickerViewControllerDelegate?
    var selectedAssetCollection: PHAssetCollection? {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byTruncatingTail
            let attributedAlbumTitle = NSAttributedString(string: selectedAssetCollection?.localizedTitle ?? "", attributes: [
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: UIScreen.main.bounds.width / 21.5, weight: .semibold)
            ])
            self.titleLabel.attributedText = attributedAlbumTitle
        }
    }
    var selectedAssetCollectionAssetCount: Int {
        if let selectedAssetCollection = self.selectedAssetCollection {
            return self.assetCounts[selectedAssetCollection] ?? Int.max
        }
        return Int.max
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        
        let viewWidth = UIScreen.main.bounds.width
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: viewWidth, height: viewWidth * 0.23)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: self.albumCellId)
        self.collectionView.register(AlbumSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId)
        
        
        // Configure the header view
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.backgroundColor = UIColor(named: "ContentCreationPage/AlbumSelectionCellBackgroundColor")!
        self.view.addSubview(self.headerView)
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.113)
        ])
        
        // Configure the close button
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.setImage(UIImage(named: "ContentCreationPage/AlbumSelectionViewControllerExitButton")!, for: .normal)
        self.closeButton.addTarget(self, action: #selector(self.userTappedExitButton), for: .touchUpInside)
        self.headerView.addSubview(self.closeButton)
        NSLayoutConstraint.activate([
            self.closeButton.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.closeButton.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor, constant: viewWidth * 0.042),
            self.closeButton.heightAnchor.constraint(equalToConstant: viewWidth * 0.0468),
            self.closeButton.widthAnchor.constraint(equalTo: self.closeButton.heightAnchor)
        ])
        
        // Configure the title label
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
            self.titleLabel.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.6)
        ])
        
        // Configure the divider view
        self.dividerView.translatesAutoresizingMaskIntoConstraints = false
        self.dividerView.backgroundColor = UIColor(named: "ContentCreationPage/AlbumSelectionDividerColor")!
        self.headerView.addSubview(self.dividerView)
        NSLayoutConstraint.activate([
            self.dividerView.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.dividerView.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor),
            self.dividerView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        let collectionViewBackground = UIView()
        collectionViewBackground.backgroundColor = UIColor(named: "ContentCreationPage/AlbumSelectionCellBackgroundColor")!
        self.collectionView.backgroundView = collectionViewBackground
        
        self.collectionView.indicatorStyle = .black
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.dividerView.bottomAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        //  Configure the fetch options
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
        fetchOptions.includeHiddenAssets = false
        
        // Only fetch recents synchronously to improve load time
        let recents = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject!
        self.keySmartAlbums.append(recents)
        self.selectedAssetCollection = recents
        self.assetCounts[recents] = recents.estimatedAssetCount
        
        DispatchQueue.global(qos: .userInitiated).async {
            var localAssetCounts: [PHAssetCollection: Int] = [:]
            var localUnknownAssetCollectionCounts: [PHAssetCollection] = []
            var localKeySmartAlbums: [PHAssetCollection] = [recents]
            var localUserAlbums: [PHAssetCollection] = []
            var localOtherSmartAlbums: [PHAssetCollection] = []
            var localThumbnailMap: [PHAssetCollection: UIImage] = [:]
            
            // Local fetch options for all fetch operations
            let fetchOptions = PHFetchOptions()
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
            fetchOptions.includeHiddenAssets = false
            
            // Fetch the smart albums
            let smartAlbumsFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            var smartAlbums = smartAlbumsFetchResult.objects(at: IndexSet(0..<smartAlbumsFetchResult.count))
            // Filter out hidden album and empty albums
            smartAlbums.removeAll {$0.estimatedAssetCount == 0 || $0.localizedTitle!.lowercased().contains("hidden")}
            smartAlbums.forEach {
                localAssetCounts[$0] = $0.estimatedAssetCount
                if $0.estimatedAssetCount == NSNotFound {
                    localUnknownAssetCollectionCounts.append($0)
                }
            }
            
            // remove recents since it was already fetch during synchronous initialization
            smartAlbums.removeAll { $0.localizedTitle!.lowercased().contains("recent") }
            
            // Get the favorites album
            let favoritesIndex = smartAlbums.firstIndex(where: { $0.localizedTitle!.lowercased().contains("favorite") })!
            localKeySmartAlbums.append(smartAlbums[favoritesIndex])
            smartAlbums.remove(at: favoritesIndex)
            
            // Set the other smart albums
            localOtherSmartAlbums = smartAlbums
            // Fetch the user albums
            let userAlbumsFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
            localUserAlbums = userAlbumsFetchResult.objects(at: IndexSet(0..<userAlbumsFetchResult.count)).sorted { $0.localizedTitle!.lowercased() < $1.localizedTitle!.lowercased() }
            localUserAlbums.removeAll { $0.estimatedAssetCount == 0 }
            localUserAlbums.forEach {
                localAssetCounts[$0] = $0.estimatedAssetCount
                if $0.estimatedAssetCount == NSNotFound {
                    localUnknownAssetCollectionCounts.append($0)
                }
            }
            
            // Reconcile assets counts and remove empty albums
            for assetCollection in localUnknownAssetCollectionCounts {
                let assetCount = PHAsset.fetchAssets(in: assetCollection, options: nil).count
                localAssetCounts[assetCollection] = assetCount
                if assetCount == 0 {
                    localAssetCounts[assetCollection] = nil
                    if let ix = localKeySmartAlbums.firstIndex(of: assetCollection) {
                        localKeySmartAlbums.remove(at: ix)
                    } else if let ix = localUserAlbums.firstIndex(of: assetCollection) {
                        localUserAlbums.remove(at: ix)
                    } else {
                        localOtherSmartAlbums.removeAll { $0 == assetCollection }
                    }
                }
            }
            
            // fetch thumbnails {
            let thumbnailFetchOpts = PHFetchOptions()
            thumbnailFetchOpts.fetchLimit = 1
            thumbnailFetchOpts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            for assetCollection in localAssetCounts.keys {
                guard let thumbnailAsset = PHAsset.fetchAssets(in: assetCollection, options: thumbnailFetchOpts).firstObject else { continue }
                let imageSideLength = (UIScreen.main.bounds.width * 0.2) * UIScreen.main.scale
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.isNetworkAccessAllowed = true
                requestOptions.resizeMode = .exact
                requestOptions.version = .current
                PHImageManager.default().requestImage(for: thumbnailAsset, targetSize: .init(width: imageSideLength, height: imageSideLength), contentMode: .aspectFill, options: requestOptions) { img, _ in
                    if let image = img {
                        localThumbnailMap[assetCollection] = image
                    }
                }
            }
            // Sync data to VC on the main thread
            DispatchQueue.main.async {
                self.keySmartAlbums = Array(localKeySmartAlbums)
                self.userAlbums = Array(localUserAlbums)
                self.otherSmartAlbums = Array(localOtherSmartAlbums)
                self.assetCounts = localAssetCounts
                self.thumbnailMap = localThumbnailMap
                self.collectionView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return .zero
        default:
            return CGSize(width: self.collectionView.bounds.width, height: self.collectionView.bounds.width * 0.0937)
        }
    }
    
    
    @objc private func userTappedExitButton() {
        self.delegate?.albumPickerViewControllerDidCancel(self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width * 0.232
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAlbum = {
            switch indexPath.section {
            case 0:
                return self.keySmartAlbums[indexPath.row]
            case 1:
                return self.userAlbums[indexPath.row]
            default:
                return self.otherSmartAlbums[indexPath.row]
            }
        }()
        self.selectedAssetCollection = selectedAlbum
        delegate?.albumPickerViewControllerDidPickAlbum(self)
        self.collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return keySmartAlbums.count
        case 1:
            return userAlbums.count
        default:
            return otherSmartAlbums.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.albumCellId, for: indexPath) as! AlbumCollectionViewCell
        let album = {
            switch indexPath.section {
            case 0:
                return self.keySmartAlbums[indexPath.row]
            case 1:
                return self.userAlbums[indexPath.row]
            default:
                return self.otherSmartAlbums[indexPath.row]
            }
        }()
        cell.albumTitle = album.localizedTitle!
        cell.albumAssetCount = self.assetCounts[album]
        if let thumbnail = self.thumbnailMap[album] {
            cell.albumCoverImage = thumbnail
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.sectionHeaderId, for: indexPath) as! AlbumSectionHeaderView
        
        let headerTitle = (indexPath.section == 1) ? "MY ALBUMS" : "MEDIA TYPES"
        
        header.sectionName = headerTitle
        return header
    }
}

protocol AlbumPickerViewControllerDelegate {
    
    func albumPickerViewControllerDidCancel(_ viewController: AlbumPickerViewController)
    
    func albumPickerViewControllerDidPickAlbum(_ viewController: AlbumPickerViewController)
}
