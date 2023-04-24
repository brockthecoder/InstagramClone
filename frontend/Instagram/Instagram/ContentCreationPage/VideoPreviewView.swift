//
//  VideoPreviewView.swift
//  InstagramClone
//
//  Created by brock davis on 10/16/22.
//

import UIKit
import AVFoundation

class VideoPreviewView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        self.layer as! AVCaptureVideoPreviewLayer
    }

}
