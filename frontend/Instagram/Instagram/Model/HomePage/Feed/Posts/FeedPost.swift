//
//  FeedPost.swift
//  Instagram
//
//  Created by brock davis on 3/5/23.
//

import UIKit
import UniformTypeIdentifiers
import ImageIO
import AVFoundation

class FeedPost: Equatable {
    
    let id: String
    
    let type: PostType
    
    let creator: FeedUser
    
    let location: FeedPostLocation?
    
    let caption: String?
    
    let commentCount: Int
    
    let commentDisabled: Bool
    
    let topComments: [FeedPostComment]
    
    let likeCount: Int
    
    let likeCountHidden: Bool
    
    let timestamp: Date
    
    let topLikers: [FeedUser]
    
    let hasUserTags: [Bool]
    
    private let mediaURLs: [URL]
    
    let audio: PostAudio?
    
    init(id: String, type: PostType, creator: FeedUser, location: FeedPostLocation? = nil, caption: String? = nil, commentCount: Int = 0, commentDisabled: Bool = false, topComments: [FeedPostComment] = [], likeCount: Int, likeCountHidden: Bool = false, timestamp: Date, hasUserTags: [Bool], topLikers: [FeedUser] = [], mediaURLs: [URL], audio: PostAudio? = nil) {
        self.id = id
        self.type = type
        self.creator = creator
        self.location = location
        self.caption = caption
        self.commentCount = commentCount
        self.commentDisabled = commentDisabled
        self.topComments = topComments
        self.likeCount = likeCount
        self.likeCountHidden = likeCountHidden
        self.timestamp = timestamp
        self.hasUserTags = hasUserTags
        self.topLikers = topLikers
        self.mediaURLs = mediaURLs.sorted{ $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        self.audio = audio
    }
    static func == (lhs: FeedPost, rhs: FeedPost) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func assets() -> [AVAsset] {
        guard
            let firstURL = self.mediaURLs.first,
            let dataType = UTType(filenameExtension: firstURL.pathExtension),
            dataType.conforms(to: .movie)
        else {
            return []
        }
        return self.mediaURLs.map { AVURLAsset(url: $0) }
    }
    
    
    func images() -> [UIImage] {
        guard
            let firstURL = self.mediaURLs.first,
            let dataType = UTType(filenameExtension: firstURL.pathExtension),
            dataType.conforms(to: .image)
        else {
            return []
        }
        return self.mediaURLs.compactMap {
            guard let data = try? Data(contentsOf: $0) else { return nil }
            return UIImage(data: data)
    }
    }
    
    var aspectHeightMultiplier: CGFloat {
        guard let firstURL = self.mediaURLs.first else { return .zero }
        
        let dataType = UTType(filenameExtension: firstURL.pathExtension)!
        if dataType.conforms(to: .image) {
            let imageSource = CGImageSourceCreateWithURL(self.mediaURLs.first! as CFURL, nil)!
            let imageProperties = (CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) ?? [:]) as NSDictionary
            let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as! NSNumber
            let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as! NSNumber
            return CGFloat(exactly: pixelHeight)! / CGFloat(exactly: pixelWidth)!
        } else {
            let asset = AVURLAsset(url: firstURL, options: [:])
            let videoSize = asset.tracks(withMediaType: .video).first!.naturalSize
            return videoSize.height / videoSize.width
        }
    }

}
