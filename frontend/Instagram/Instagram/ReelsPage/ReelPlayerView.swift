//
//  ReelPlayerView.swift
//  InstagramClone
//
//  Created by brock davis on 12/27/22.
//

import UIKit
import AVFoundation

class ReelPlayerView: UIView {
    
    private let muteRecognizer = UITapGestureRecognizer()
    private let pauseRecognizer = UILongPressGestureRecognizer()

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        
    }
    
    @objc private func userToggledMute(recognizer: UITapGestureRecognizer) {
        if let player = self.playerLayer.player {
            player.pause()
        }
    }

}

private struct Configurations {
    
}
