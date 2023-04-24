//
//  ReelManager.swift
//  InstagramClone
//
//  Created by brock davis on 11/30/22.
//

import UIKit
import AVFoundation

class CachingReelManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    typealias ReelID = NSString
    typealias TaskID = Int
    
    private let playerItemCache = NSCache<ReelID, AVPlayerItem>()
    private var downloadTasks: [TaskID: ReelID] = [:]
    private var waitingCallbacks: [TaskID: (AVPlayerItem?) -> ()] = [:]
    private var urlSession: URLSession!
    private let operationQueue = DispatchQueue(label: "ReelManagerOperationsQueue", qos: .userInitiated)
    private lazy var tempStorageDirectory: URL = {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let tempStorageDirectoryName = "reelsTempStorage"
        let tempStorageDirectoryURL = tempDirectory.appendingPathComponent(tempStorageDirectoryName)
        try! fileManager.createDirectory(at: tempStorageDirectoryURL, withIntermediateDirectories: true)
        return tempStorageDirectoryURL
    }()
    
    
    override init() {
        
        super.init()
        
        // Configure the url session
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.networkServiceType = .responsiveAV
        sessionConfiguration.allowsCellularAccess = true
        sessionConfiguration.timeoutIntervalForRequest = 30 as TimeInterval
        sessionConfiguration.timeoutIntervalForResource = 360 as TimeInterval
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.allowsConstrainedNetworkAccess = true
        sessionConfiguration.allowsExpensiveNetworkAccess = true
        
        self.urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    
        
        // Configure the cache
        self.playerItemCache.name = "PlayerItemCache"
        self.playerItemCache.countLimit = 10
    }
    
    func startCaching(reels: [Reel]) {
        
        for reel in reels {
            if !self.downloadTasks.values.contains(reel.id as NSString) && self.playerItemCache.object(forKey: reel.id as NSString) == nil {
                if let playerItemFromDisk = self.playerItemFromDisk(forReel: reel) {
                    self.playerItemCache.setObject(playerItemFromDisk, forKey: reel.id as NSString)
                    continue
                }
                self.startDownloadTask(forReel: reel)
            }
        }
    }
    
    @discardableResult
    private func startDownloadTask(forReel reel: Reel) -> Int {
        let request = URLRequest(url: reel.mediaURL)
        let downloadTask = self.urlSession.downloadTask(with: request)
        self.downloadTasks[downloadTask.taskIdentifier] = reel.id as NSString
        downloadTask.resume()
        return downloadTask.taskIdentifier
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.operationQueue.async {
            let fileManager = FileManager.default
            let reelID = self.downloadTasks[downloadTask.taskIdentifier]!
            let reelMediaURL = self.tempStorageDirectory.appendingPathExtension(reelID as String)
            try! fileManager.copyItem(at: location, to: reelMediaURL)
            
            let asset = AVURLAsset(url: reelMediaURL)
            let playerItem = AVPlayerItem(asset: asset)
            self.playerItemCache.setObject(playerItem, forKey: reelID)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let callback = self.waitingCallbacks[task.taskIdentifier] {
            callback(self.playerItemCache.object(forKey: self.downloadTasks[task.taskIdentifier]!))
            self.waitingCallbacks[task.taskIdentifier] = nil
        }
        self.downloadTasks[task.taskIdentifier] = nil
    }
    
    func stopCaching(reels: [Reel]) {
        var taskIDsToCancel: Set<TaskID> = []
        for reel in reels {
            let reelID = reel.id as NSString
            self.playerItemCache.removeObject(forKey: reelID)
            if self.downloadTasks.values.contains(reelID) {
                taskIDsToCancel.insert(self.downloadTasks.keys.first(where: { self.downloadTasks[$0] == reelID })!)
            }
        }
        
        self.urlSession.getAllTasks { tasks in
            let tasksToCancel = tasks.filter { taskIDsToCancel.contains($0.taskIdentifier) }
            tasksToCancel.forEach {
                $0.cancel()
                self.downloadTasks[$0.taskIdentifier] = nil
            }
        }
    }
    
    private func playerItemFromDisk(forReel reel: Reel) -> AVPlayerItem? {
        let mediaURL = self.tempStorageDirectory.appendingPathComponent(reel.id)
        guard
            let mediaIsReachable = try? mediaURL.checkResourceIsReachable(),
            mediaIsReachable
        else { return nil }
        
        return AVPlayerItem(url: mediaURL)
    }
    
    func requestPlayerItem(for reel: Reel, resultHandler: @escaping (AVPlayerItem?) -> ()) {
        self.operationQueue.async {
            if let cachedPlayerItem = self.playerItemCache.object(forKey: reel.id as NSString) {
                resultHandler(cachedPlayerItem)
            } else if let playerItemFromDisk = self.playerItemFromDisk(forReel: reel) {
                resultHandler(playerItemFromDisk)
            } else {
                let taskID = self.startDownloadTask(forReel: reel)
                self.waitingCallbacks[taskID] = resultHandler
            }
        }
    }
}
