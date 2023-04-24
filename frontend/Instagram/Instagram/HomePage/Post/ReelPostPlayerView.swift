//
//  ReelPostPlayerView.swift
//  Instagram
//
//  Created by brock davis on 3/5/23.
//

import UIKit
import AVFoundation

class ReelPostPlayerView: UIView {
    
    private(set) var isMuted = true {
        didSet {
            self.unmuteAudioButton.isSelected = !isMuted
            self.queuePlayer.isMuted = isMuted
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    func startPlaying() {
        self.queuePlayer.rate = 1
    }
    
    func stopPlaying() {
        self.queuePlayer.rate = 0
    }
    
    var playing: Bool {
        self.queuePlayer.rate > 0
    }

    var asset: AVAsset? {
        didSet {
            if let looper = self.playerLooper {
                looper.disableLooping()
                self.queuePlayer.replaceCurrentItem(with: nil)
            }
            if let asset {
                let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [#keyPath(AVAsset.duration)])
                self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)
                self.queuePlayer.actionAtItemEnd = .pause
            }
        }
    }
    
    var hasTaggedUsers: Bool = false {
        didSet {
            self.taggedUsersButton.isHidden = !hasTaggedUsers
        }
    }
    
    private let queuePlayer: AVQueuePlayer
    private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer {
        self.layer as! AVPlayerLayer
    }
    private let unmuteAudioButton = UIButton()
    private let taggedUsersButton = UIButton()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        self.queuePlayer = AVQueuePlayer()
        super.init(frame: .zero)
        self.playerLayer.player = self.queuePlayer
        self.playerLayer.videoGravity = .resizeAspectFill
        self.queuePlayer.isMuted = true
        
        self.unmuteAudioButton.setBackgroundImage(Configurations.unmuteAudioButtonBackgroundImage(isMuted: true), for: .normal)
        self.unmuteAudioButton.setBackgroundImage(Configurations.unmuteAudioButtonBackgroundImage(isMuted: false), for: .selected)
        self.unmuteAudioButton.addTarget(self, action: #selector(self.userTappedUnmuteAudioButton), for: .touchUpInside)
        self.addSubview(self.unmuteAudioButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Configurations.unmuteAudioButtonTrailingSpacing),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Configurations.unmuteAudioButtonBottomSpacing)
            ])
        }
        
        self.taggedUsersButton.setBackgroundImage(Configurations.taggedUsersButtonBackgroundImage, for: .normal)
        self.taggedUsersButton.layer.shadowOpacity = Configurations.taggedUsersButtonShadowOpacity
        self.taggedUsersButton.layer.shadowOffset = Configurations.taggedUsersButtonShadowOffset
        self.taggedUsersButton.isHidden = true
        self.addSubview(self.taggedUsersButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.shadowRadius = 1.0
            $0.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            $0.layer.shadowOpacity = 0.3
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Configurations.taggedUsersButtonLeadingConstant),
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: Configurations.taggedUsersButtonBottomConstant)
            ])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMuteStatus), name: AppDelegate.muteStatusDidChangeNotification, object: nil)
    }
    
    @objc private func updateMuteStatus(muteStatusNotification: NSNotification) {
        guard let muteStatus = muteStatusNotification.userInfo?[AppDelegate.muteStatusNotificationKey] as? Bool else { return }
        self.isMuted = muteStatus
        
    }
    
    @objc private func userTappedUnmuteAudioButton() {
        NotificationCenter.default.post(name: AppDelegate.muteStatusDidChangeNotification, object: self, userInfo: [AppDelegate.muteStatusNotificationKey: !self.queuePlayer.isMuted])
    }

}

private struct Configurations {
    
    static let unmuteAudioButtonTrailingSpacing: CGFloat = 14.0
    
    static let unmuteAudioButtonBottomSpacing = unmuteAudioButtonTrailingSpacing
    
    static let unmuteAudioButtonSize = CGSize.sqaure(size: 26)
    
    static let audioIconSize = CGSize.sqaure(size: 11)
    
    static let audioMutedIcon = UIImage(named: "HomePage/Feed/Reels/audioMutedIcon")!.resizedTo(size: audioIconSize).withTintColor(.white)
    
    static let audioPlayingIcon = UIImage(named: "HomePage/Feed/Reels/audioPlayingIcon")!.resizedTo(size: audioIconSize).withTintColor(.white)
    
    static let audioButtonBackgroundColor = UIColor(named: "HomePage/Feed/Post/overlayButtonBackgroundColor")!.withAlphaComponent(0.6)
    
    static func unmuteAudioButtonBackgroundImage(isMuted: Bool) -> UIImage {
        return UIGraphicsImageRenderer(size: unmuteAudioButtonSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(audioButtonBackgroundColor.cgColor)
            let backgroundRect = CGRect(origin: .zero, size: unmuteAudioButtonSize)
            context.addEllipse(in: backgroundRect)
            context.fillPath()
            let icon = isMuted ? audioMutedIcon : audioPlayingIcon
            icon.draw(at: CGPoint(x: backgroundRect.midX - (audioIconSize.width / 2), y: backgroundRect.midY - (audioIconSize.height / 2)))
        }
    }
    
    static let taggedUsersIconSize = CGSize.sqaure(size: 10)
    static let taggedUsersIcon = UIImage(named: "HomePage/Feed/Post/taggedUsersIcon")!.resizedTo(size: taggedUsersIconSize).withTintColor(.white)
    static let taggedUsersButtonSize = CGSize.sqaure(size: 26)
    static let taggedUsersButtonBackgroundColor = UIColor(named: "HomePage/Feed/Post/overlayButtonBackgroundColor")!.withAlphaComponent(0.9)
    static let taggedUsersButtonShadowOpacity: Float = 0.3
    static let taggedUsersButtonShadowOffset = CGSize(width: 1.5 / 3.0, height: 1.5 / 3.0)
    static let taggedUsersButtonBackgroundImage = {
        return UIGraphicsImageRenderer(size: taggedUsersButtonSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(taggedUsersButtonBackgroundColor.cgColor)
            let backgroundRect = CGRect(origin: .zero, size: taggedUsersButtonSize)
            context.addEllipse(in: backgroundRect)
            context.fillPath()
            taggedUsersIcon.draw(at: CGPoint(x: backgroundRect.midX - (taggedUsersIconSize.width / 2), y: backgroundRect.midY - (taggedUsersIconSize.height / 2)))
        }
    }()
    static let taggedUsersButtonLeadingConstant: CGFloat = 14.0
    static let taggedUsersButtonBottomConstant: CGFloat = -14.0
}

