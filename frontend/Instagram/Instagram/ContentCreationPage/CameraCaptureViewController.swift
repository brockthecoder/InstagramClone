//
//  CameraCaptureViewController.swift
//  InstagramClone
//
//  Created by brock davis on 10/18/22.
//

import UIKit
import AVFoundation

class CameraCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // Unauthorized views
    private let unauthorizedIconView = UIImageView()
    private let unauthorizedHeadingLabel = UILabel()
    private let cameraMicrophoneUsageDescriptionLabel = UILabel()
    private let openSettingsButton = UIButton()
    private lazy var unauthorizedViews: [UIView] = [unauthorizedIconView, unauthorizedHeadingLabel, cameraMicrophoneUsageDescriptionLabel, openSettingsButton]
    private weak var photoLibraryVC: PhotoLibraryAssetSelectionViewController?
    private var videoPreview: VideoPreviewView
    private let videoPreviewBlurView = UIVisualEffectView()
    private var captureSession: AVCaptureSession!
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var currentCameraPosition: AVCaptureDevice.Position
    private var currentFlashMode: AVCaptureDevice.FlashMode = .on
    private let flashModeIcons: [AVCaptureDevice.FlashMode: UIImage] = [.on: UIImage(named: "ContentCreationPage/FlashEnabledIcon")!, .auto: UIImage(named: "ContentCreationPage/FlashAutoIcon")!, .off: UIImage(named: "ContentCreationPage/FlashDisabledIcon")!]
    private var photoOutput: AVCapturePhotoOutput!
    private let exitButton = UIButton()
    private let flashButton = UIButton()
    private let settingsButton = UIButton()
    private let photoLibraryButton = UIButton()
    private let cameraSwapButton = UIButton()
    private let cameraCaptureButton = UIButton()
    private var cameraCaptureButtonBottomConstraint: NSLayoutConstraint!
    private let firstFilter = UIImageView()
    private let secondFilter = UIImageView()
    private let textSubmodeButton = UIButton()
    private let textSubmodeLabel = UILabel()
    private let boomerangSubmodeButton = UIButton()
    private let boomerangSubmodeLabel = UILabel()
    private let gridSubmodeButton = UIButton()
    private let gridSubmodeLabel = UILabel()
    private let submodeExpansionButton = UIButton()
    private lazy var cameraTaskQueue = DispatchQueue(label: "cameraTaskQueue", qos: .userInitiated)
    private var thumbnailObservationReference: NSKeyValueObservation?
    private let captureModeSelectionView = CaptureModeSelectionView(modes: ["POST", "STORY", "REEL", "LIVE"])
    private let previewGestureRegionView = UIView()
    private let cameraSwapTapRecognizer = UITapGestureRecognizer()
    private let unauthorizedHiddenViews: [UIView]
    private var captureSessionCanRun: Bool {
        self.cameraAndMicrophoneAccessGranted &&  !self.captureSession.inputs.isEmpty
    }
    
    private var cameraAndMicrophoneAccessGranted: Bool = false {
        didSet {
            if cameraAndMicrophoneAccessGranted {
                
                // Create and configure the capture session
                self.captureSession = AVCaptureSession()
                self.captureSession.sessionPreset = .photo
                self.captureSession.beginConfiguration()
                
                // Find the capture devices
                let frontCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
                let backCameraDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
                
                // Create the capture device inputs
                let frontCamera = frontCameraDiscoverySession.devices.first
                self.frontCameraInput = (frontCamera != nil) ? try? AVCaptureDeviceInput(device: frontCamera!) : nil
                let backCamera = backCameraDiscoverySession.devices.first
                self.backCameraInput = (backCamera != nil) ? try? AVCaptureDeviceInput(device: backCamera!) : nil
                
                // Add one of the capture device inputs to the capture session
                if self.currentCameraPosition == .front, let frontCameraInput, self.captureSession.canAddInput(frontCameraInput) {
                    self.captureSession.addInput(frontCameraInput)
                } else if self.currentCameraPosition == .back, let backCameraInput, self.captureSession.canAddInput(backCameraInput) {
                    self.captureSession.addInput(backCameraInput)
                } else if (backCameraInput != nil && self.captureSession.canAddInput(backCameraInput!)) || (frontCameraInput != nil && self.captureSession.canAddInput(frontCameraInput!)) {
                    self.captureSession.addInput((self.frontCameraInput != nil) ? self.frontCameraInput! : self.backCameraInput!)
                    self.currentCameraPosition = (self.frontCameraInput != nil) ? .front : .back
                } else {
                    print("unable to add either camera device input")
                    return
                }
                
                // Configure the video preview layer
                self.videoPreview.previewLayer.session = self.captureSession
                
                // Front facing camera output should be mirrored
                if self.currentCameraPosition == .front && self.videoPreview.previewLayer.connection!.isVideoMirroringSupported {
                    print("setting up video mirroring for preview layer")
                    self.videoPreview.previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
                    self.videoPreview.previewLayer.connection!.isVideoMirrored = true
                }
                
                // Create the photo output
                self.photoOutput = AVCapturePhotoOutput()
                
                // Verify session can add the photo output
                guard self.captureSession.canAddOutput(self.photoOutput) else {
                    print("unable to add photo output to capture session")
                    return
                }
                self.captureSession.addOutput(self.photoOutput)
                
                // Mirror the camera output if the current camera is the front camera
                if self.photoOutput.connection(with: .video)!.isVideoMirroringSupported && self.currentCameraPosition == .front {
                    print("setting up video mirroring for output")
                    self.photoOutput.connection(with: .video)!.automaticallyAdjustsVideoMirroring = false
                    self.photoOutput.connection(with: .video)!.isVideoMirrored = true
                }
                
                self.captureSession.commitConfiguration()
                self.cameraCaptureButtonBottomConstraint.isActive = false
                self.cameraCaptureButtonBottomConstraint = self.cameraCaptureButton.bottomAnchor.constraint(equalTo: self.videoPreview.bottomAnchor, constant: -Configurations.screenWidth * 0.061)
                self.cameraCaptureButtonBottomConstraint.isActive = true
                self.unauthorizedViews.forEach { $0.isHidden = true }
                self.unauthorizedHiddenViews.forEach { $0.isHidden = false }
                self.cameraCaptureButton.alpha = 1
                self.previewGestureRegionView.isHidden = true
                self.flashButton.alpha = 0
            }
        }
    }
    

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(cameraPosition: AVCaptureDevice.Position = .front, photoLibraryVC: PhotoLibraryAssetSelectionViewController) {
        
        self.unauthorizedHiddenViews = [
            self.flashButton, self.settingsButton, self.textSubmodeButton, self.textSubmodeLabel, self.textSubmodeLabel,
            self.boomerangSubmodeButton, self.boomerangSubmodeLabel, self.gridSubmodeButton, self.gridSubmodeLabel,
            self.submodeExpansionButton, self.firstFilter, self.secondFilter, self.cameraSwapButton, self.previewGestureRegionView,
            self.videoPreviewBlurView
        ]
        
        self.photoLibraryVC = photoLibraryVC
        self.currentCameraPosition = cameraPosition
        
        // Create and configure the video preview layer
        self.videoPreview = VideoPreviewView()
        self.videoPreview.previewLayer.videoGravity = .resizeAspectFill
    
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        
        self.cameraSwapTapRecognizer.numberOfTapsRequired = 2
        self.cameraSwapTapRecognizer.numberOfTouchesRequired = 1
        self.cameraSwapTapRecognizer.addTarget(self, action: #selector(self.userTappedCameraToggleButton))
        self.previewGestureRegionView.addGestureRecognizer(self.cameraSwapTapRecognizer)
        
        let viewWidth = UIScreen.main.bounds.width

        // Configure buttons
        self.exitButton.setBackgroundImage(Configurations.exitButtonIcon, for: .normal)
        self.exitButton.addTarget(self, action: #selector(self.userTappedExitButton), for: .touchUpInside)
        self.flashButton.setBackgroundImage(self.flashModeIcons[.off], for: .normal)
        self.flashButton.addTarget(self, action: #selector(self.userTappedFlashButton), for: .touchUpInside)
        self.settingsButton.setBackgroundImage(UIImage(named: "ContentCreationPage/ContentCreateSettingsIcon")!, for: .normal)
        self.settingsButton.addTarget(self, action: #selector(self.userTappedSettingsButton), for: .touchUpInside)
        self.textSubmodeButton.setBackgroundImage(UIImage(named: "ContentCreationPage/TextSubmodeIcon")!, for: .normal)
        self.textSubmodeButton.addTarget(self, action: #selector(self.userTappedSubmodeButton(sender:)), for: .touchUpInside)
        self.boomerangSubmodeButton.setBackgroundImage(UIImage(named: "ContentCreationPage/BoomerangSubmodeIcon")!, for: .normal)
        self.boomerangSubmodeButton.addTarget(self, action: #selector(self.userTappedSubmodeButton(sender:)), for: .touchUpInside)
        self.gridSubmodeButton.setBackgroundImage(UIImage(named: "ContentCreationPage/GridSubmodeIcon")!, for: .normal)
        self.gridSubmodeButton.addTarget(self, action: #selector(self.userTappedSubmodeButton(sender:)), for: .touchUpInside)
        self.submodeExpansionButton.setBackgroundImage(UIImage(named: "ContentCreationPage/SubmodeExpansionIcon")!, for: .normal)
        self.submodeExpansionButton.addTarget(self, action: #selector(self.userTappedSubmodeButton(sender:)), for: .touchUpInside)
        self.cameraCaptureButton.setBackgroundImage(Configurations.captureButtonImage, for: .normal)
        self.cameraCaptureButton.addTarget(self, action: #selector(self.userTappedCaptureButton), for: .touchUpInside)
        self.cameraCaptureButton.layer.shadowOpacity = 0.1
        self.cameraCaptureButton.layer.shadowRadius = 1.5
        self.firstFilter.image = UIImage(named: "ContentCreationPage/Filter1Preview")!
        self.firstFilter.layer.shadowOpacity = 0.1
        self.firstFilter.layer.shadowRadius = 1.5
        self.secondFilter.image = UIImage(named: "ContentCreationPage/Filter2Preview")!
        self.secondFilter.layer.shadowOpacity = 0.1
        self.secondFilter.layer.shadowRadius = 1.5
        self.thumbnailObservationReference = self.photoLibraryVC!.observe(\PhotoLibraryAssetSelectionViewController.currentThumbnail, options: [.initial, .new]) { vc, change in
            if let thumbnail = self.photoLibraryVC?.currentThumbnail {
                self.photoLibraryButton.setBackgroundImage(Configurations.photoLibraryButtonImage(forThumbnail: thumbnail), for: .normal)
            } else {
                self.photoLibraryButton.setBackgroundImage(Configurations.missingThumbnailIcon, for: .normal)
            }
        }
        self.photoLibraryButton.addTarget(self, action: #selector(self.userTappedPhotoLibraryButton), for: .touchUpInside)
        self.cameraSwapButton.setBackgroundImage(Configurations.cameraSwapButtonImage, for: .normal)
        self.cameraSwapButton.addTarget(self, action: #selector(self.userTappedCameraToggleButton), for: .touchUpInside)
        
        // Setup Layout constraints
        
        // Add the video capture preview layer
        self.videoPreview.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.backgroundColor = .black
        self.view.addSubview(self.videoPreview)
        self.videoPreview.layer.cornerRadius = 23
        NSLayoutConstraint.activate([
            self.videoPreview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.videoPreview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.videoPreview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Configurations.videoPreviewViewTopSpacing),
            self.videoPreview.heightAnchor.constraint(equalToConstant: Configurations.videoPreviewViewHeight)
        ])
        
        // Configure and add the blur effect view
        self.videoPreviewBlurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        self.videoPreviewBlurView.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.videoPreviewBlurView)
        NSLayoutConstraint.activate([
            self.videoPreviewBlurView.leadingAnchor.constraint(equalTo: self.videoPreview.leadingAnchor),
            self.videoPreviewBlurView.trailingAnchor.constraint(equalTo: self.videoPreview.trailingAnchor),
            self.videoPreviewBlurView.topAnchor.constraint(equalTo: self.videoPreview.topAnchor),
            self.videoPreviewBlurView.bottomAnchor.constraint(equalTo: self.videoPreview.bottomAnchor)
        ])
        
        // Add the exit button
        self.exitButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.exitButton)
        NSLayoutConstraint.activate([
            self.exitButton.leadingAnchor.constraint(equalTo: self.videoPreview.leadingAnchor, constant: Configurations.exitButtonLeadingSpacing),
            self.exitButton.topAnchor.constraint(equalTo: self.videoPreview.topAnchor, constant: Configurations.exitButtonTopSpacing)
        ])
        
        // Add the flash button
        self.flashButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.flashButton)
        NSLayoutConstraint.activate([
            self.flashButton.centerYAnchor.constraint(equalTo: self.exitButton.centerYAnchor),
            self.flashButton.centerXAnchor.constraint(equalTo: self.videoPreview.centerXAnchor),
            self.flashButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.061),
            self.flashButton.heightAnchor.constraint(equalTo: self.flashButton.widthAnchor, multiplier: 1.12)
        ])
        
        // Add the settings button
        self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.settingsButton)
        NSLayoutConstraint.activate([
            self.settingsButton.centerYAnchor.constraint(equalTo: self.flashButton.centerYAnchor),
            self.settingsButton.trailingAnchor.constraint(equalTo: self.videoPreview.trailingAnchor, constant: -viewWidth * 0.0488),
            self.settingsButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.0688),
            self.settingsButton.heightAnchor.constraint(equalTo: self.settingsButton.widthAnchor)
        ])
        
        // Add the submode expansion button
        self.submodeExpansionButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.submodeExpansionButton)
        NSLayoutConstraint.activate([
            self.submodeExpansionButton.centerXAnchor.constraint(equalTo: self.videoPreview.leadingAnchor, constant: viewWidth * 0.0854),
            self.submodeExpansionButton.bottomAnchor.constraint(equalTo: self.videoPreview.bottomAnchor, constant: -viewWidth * 0.6177),
            self.submodeExpansionButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.0561),
            self.submodeExpansionButton.heightAnchor.constraint(equalTo: self.submodeExpansionButton.widthAnchor, multiplier: 0.565)
        ])
        
        let centerToCenterSubmodeButtonSpacing = viewWidth * 0.127
        
        // Add the grid submode button
        self.gridSubmodeButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.gridSubmodeButton)
        NSLayoutConstraint.activate([
            self.gridSubmodeButton.centerXAnchor.constraint(equalTo: self.submodeExpansionButton.centerXAnchor),
            self.gridSubmodeButton.centerYAnchor.constraint(equalTo: self.submodeExpansionButton.centerYAnchor, constant: -centerToCenterSubmodeButtonSpacing),
            self.gridSubmodeButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.061),
            self.gridSubmodeButton.heightAnchor.constraint(equalTo: self.gridSubmodeButton.widthAnchor)
        ])
        
        let submodeLabelFont = UIFont.systemFont(ofSize: viewWidth * 0.03, weight: .semibold)
        
        // Add the grid submode label
        let gridSubmodeText = NSAttributedString(string: "Layout", attributes: [
            .foregroundColor: UIColor.white,
            .font: submodeLabelFont
        ])
        self.gridSubmodeLabel.attributedText = gridSubmodeText
        self.gridSubmodeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.gridSubmodeLabel)
        NSLayoutConstraint.activate([
            self.gridSubmodeLabel.centerYAnchor.constraint(equalTo: self.gridSubmodeButton.centerYAnchor),
            self.gridSubmodeLabel.leadingAnchor.constraint(equalTo: self.gridSubmodeButton.trailingAnchor, constant: viewWidth * 0.047)
        ])
        
        // Add the boomerang submode button
        self.boomerangSubmodeButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.boomerangSubmodeButton)
        NSLayoutConstraint.activate([
            self.boomerangSubmodeButton.centerXAnchor.constraint(equalTo: self.gridSubmodeButton.centerXAnchor),
            self.boomerangSubmodeButton.centerYAnchor.constraint(equalTo: self.gridSubmodeButton.centerYAnchor, constant: -centerToCenterSubmodeButtonSpacing),
            self.boomerangSubmodeButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.06),
            self.boomerangSubmodeButton.heightAnchor.constraint(equalTo: self.boomerangSubmodeButton.widthAnchor, multiplier: 0.522)
        ])
        
        // Add the boomerang submode label
        let boomerangSubmodeText = NSAttributedString(string: "Boomerang", attributes: [
            .foregroundColor: UIColor.white,
            .font: submodeLabelFont
        ])
        self.boomerangSubmodeLabel.attributedText = boomerangSubmodeText
        self.boomerangSubmodeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.boomerangSubmodeLabel)
        NSLayoutConstraint.activate([
            self.boomerangSubmodeLabel.centerYAnchor.constraint(equalTo: self.boomerangSubmodeButton.centerYAnchor),
            self.boomerangSubmodeLabel.leadingAnchor.constraint(equalTo: self.gridSubmodeLabel.leadingAnchor)
        ])
        
        // Add the text submode
        self.textSubmodeButton.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.textSubmodeButton)
        NSLayoutConstraint.activate([
            self.textSubmodeButton.centerXAnchor.constraint(equalTo: self.boomerangSubmodeButton.centerXAnchor),
            self.textSubmodeButton.centerYAnchor.constraint(equalTo: self.boomerangSubmodeButton.centerYAnchor, constant: -centerToCenterSubmodeButtonSpacing),
            self.textSubmodeButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.051),
            self.textSubmodeButton.heightAnchor.constraint(equalTo: self.textSubmodeButton.widthAnchor, multiplier: 0.925)
        ])
        
        // Add the text submode label
        let textSubmodeText = NSAttributedString(string: "Create", attributes: [
            .foregroundColor: UIColor.white,
            .font: submodeLabelFont
        ])
        self.textSubmodeLabel.attributedText = textSubmodeText
        self.textSubmodeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.textSubmodeLabel)
        NSLayoutConstraint.activate([
            self.textSubmodeLabel.centerYAnchor.constraint(equalTo: self.textSubmodeButton.centerYAnchor),
            self.textSubmodeLabel.leadingAnchor.constraint(equalTo: self.boomerangSubmodeLabel.leadingAnchor)
        ])
        
        // Add the capture button
        self.cameraCaptureButton.translatesAutoresizingMaskIntoConstraints = false
        self.cameraCaptureButton.alpha = 0.235
        self.videoPreview.addSubview(self.cameraCaptureButton)
        self.cameraCaptureButtonBottomConstraint = self.cameraCaptureButton.bottomAnchor.constraint(equalTo: self.videoPreview.bottomAnchor)
        NSLayoutConstraint.activate([
            self.cameraCaptureButton.centerXAnchor.constraint(equalTo: self.videoPreview.centerXAnchor),
            self.cameraCaptureButtonBottomConstraint,
            self.cameraCaptureButton.widthAnchor.constraint(equalTo: self.videoPreview.widthAnchor, multiplier: 0.195),
            self.cameraCaptureButton.heightAnchor.constraint(equalTo: self.cameraCaptureButton.widthAnchor)
        ])
        
        let filterButtonSpacing = viewWidth * 0.075
        
        // Add the first filter
        self.firstFilter.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.firstFilter)
        NSLayoutConstraint.activate([
            self.firstFilter.centerYAnchor.constraint(equalTo: self.cameraCaptureButton.centerYAnchor),
            self.firstFilter.leadingAnchor.constraint(equalTo: self.cameraCaptureButton.trailingAnchor, constant: filterButtonSpacing),
            self.firstFilter.widthAnchor.constraint(equalTo: self.cameraCaptureButton.widthAnchor, multiplier: 0.625),
            self.firstFilter.heightAnchor.constraint(equalTo: self.firstFilter.widthAnchor)
        ])
        
        // Add the second filter
        self.secondFilter.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.secondFilter)
        NSLayoutConstraint.activate([
            self.secondFilter.centerYAnchor.constraint(equalTo: self.firstFilter.centerYAnchor),
            self.secondFilter.leadingAnchor.constraint(equalTo: self.firstFilter.trailingAnchor, constant: filterButtonSpacing),
            self.secondFilter.widthAnchor.constraint(equalTo: self.firstFilter.widthAnchor, multiplier: 0.7),
            self.secondFilter.heightAnchor.constraint(equalTo: self.secondFilter.widthAnchor)
        ])
        
        // Add the gesture region view
        self.previewGestureRegionView.backgroundColor = .clear
        self.previewGestureRegionView.translatesAutoresizingMaskIntoConstraints = false
        self.videoPreview.addSubview(self.previewGestureRegionView)
        NSLayoutConstraint.activate([
            self.previewGestureRegionView.topAnchor.constraint(equalTo: self.flashButton.bottomAnchor, constant: 5),
            self.previewGestureRegionView.bottomAnchor.constraint(equalTo: self.cameraCaptureButton.topAnchor, constant: 5),
            self.previewGestureRegionView.leadingAnchor.constraint(equalTo: self.boomerangSubmodeButton.trailingAnchor, constant: 5),
            self.previewGestureRegionView.trailingAnchor.constraint(equalTo: self.videoPreview.trailingAnchor)
        ])
        
        // Add the photo library button
        self.photoLibraryButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.photoLibraryButton)
        NSLayoutConstraint.activate([
            self.photoLibraryButton.centerYAnchor.constraint(equalTo: self.videoPreview.bottomAnchor, constant: Configurations.photoLibraryButtonCenterYOffset),
            self.photoLibraryButton.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Configurations.photoLibraryButtonCenterXOffset)
        ])
        
        // Add the camera swap button
        self.cameraSwapButton.translatesAutoresizingMaskIntoConstraints = false
        self.cameraSwapButton.layer.shadowOpacity = 0.5
        self.cameraSwapButton.layer.shadowRadius = viewWidth / 5
        self.view.addSubview(self.cameraSwapButton)
        NSLayoutConstraint.activate([
            self.cameraSwapButton.topAnchor.constraint(equalTo: self.videoPreview.bottomAnchor, constant: Configurations.cameraSwapButtonTopSpacing),
            self.cameraSwapButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Configurations.cameraSwapButtonTrailingSpacing)
        ])
        
        // Add the capture mode selection view
        self.captureModeSelectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(self.captureModeSelectionView, belowSubview: self.photoLibraryButton)
        NSLayoutConstraint.activate([
            self.captureModeSelectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.captureModeSelectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.captureModeSelectionView.bottomAnchor.constraint(equalTo: self.cameraSwapButton.bottomAnchor),
            self.captureModeSelectionView.topAnchor.constraint(equalTo: self.cameraSwapButton.topAnchor)
        ])
        
        // Set up the unauthorized views
        
        // Set up the unauthorized icon view
        self.unauthorizedIconView.image = Configurations.unauthorizedIconImage
        self.unauthorizedIconView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.unauthorizedIconView)
        NSLayoutConstraint.activate([
            self.unauthorizedIconView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.unauthorizedIconView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Configurations.unauthorizedIconTopSpacing),
            self.unauthorizedIconView.widthAnchor.constraint(equalToConstant: Configurations.unauthorizedIconSize.width),
            self.unauthorizedIconView.heightAnchor.constraint(equalToConstant: Configurations.unauthorizedIconSize.height)
        ])
        
        // Set up the unauthorized heading label
        self.unauthorizedHeadingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.unauthorizedHeadingLabel.attributedText = Configurations.unauthorizedHeadingLabelText
        self.unauthorizedHeadingLabel.numberOfLines = 2
        self.view.addSubview(self.unauthorizedHeadingLabel)
        NSLayoutConstraint.activate([
            self.unauthorizedHeadingLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.unauthorizedHeadingLabel.topAnchor.constraint(equalTo: self.unauthorizedIconView.bottomAnchor, constant: Configurations.unauthorizedHeadingLabelTopSpacing)
        ])
        
        // Set up the camera and microphone usage description label
        self.cameraMicrophoneUsageDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cameraMicrophoneUsageDescriptionLabel.numberOfLines = 2
        self.cameraMicrophoneUsageDescriptionLabel.attributedText = Configurations.cameraMicrophoneUsageDescriptionLabelText
        self.view.addSubview(self.cameraMicrophoneUsageDescriptionLabel)
        NSLayoutConstraint.activate([
            self.cameraMicrophoneUsageDescriptionLabel.topAnchor.constraint(equalTo: self.unauthorizedHeadingLabel.bottomAnchor, constant: Configurations.cameraMicrophoneUsageDescriptionLabelTopSpacing),
            self.cameraMicrophoneUsageDescriptionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        // Set up the open settings button
        self.openSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        self.openSettingsButton.setAttributedTitle(Configurations.openSettingsButtonText, for: .normal)
        self.openSettingsButton.addTarget(self, action: #selector(self.userTappedOpenSettingsButton), for: .touchUpInside)
        self.view.addSubview(self.openSettingsButton)
        NSLayoutConstraint.activate([
            self.openSettingsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.openSettingsButton.topAnchor.constraint(equalTo: self.cameraMicrophoneUsageDescriptionLabel.bottomAnchor, constant: Configurations.openSettingsButtonTopSpacing)
        ])
        
        self.unauthorizedHiddenViews.forEach{ $0.isHidden = true }
        
        defer {
            self.cameraAndMicrophoneAccessGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        }
    }
    
    @objc private func userTappedOpenSettingsButton() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startCaptureSessionIfStopped()
        if !self.cameraAndMicrophoneAccessGranted {
            AVCaptureDevice.requestAccess(for: .video) { accessGranted in
                DispatchQueue.main.async {
                    self.cameraAndMicrophoneAccessGranted = accessGranted
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stopCaptureSessionIfRunning()
    }
    
    func startCaptureSessionIfStopped() {
        if self.captureSessionCanRun, !self.captureSession.isRunning {
            self.cameraTaskQueue.async {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.flashButton.alpha = self.photoOutput.supportedFlashModes.firstIndex(of: .on) == nil ?  0 : 1
                    self.videoPreviewBlurView.alpha = 0
                    let swappedDeviceInput = self.captureSession.inputs.first == self.frontCameraInput ? self.backCameraInput : self.frontCameraInput
                    if swappedDeviceInput != nil {
                        self.previewGestureRegionView.isHidden = false
                    }
                }
            }
        }
    }
    
    func stopCaptureSessionIfRunning() {
        if self.captureSessionCanRun, self.captureSession.isRunning {
            self.cameraTaskQueue.async {
                self.captureSession.stopRunning()
                DispatchQueue.main.async {
                    self.flashButton.alpha = 0
                    self.videoPreviewBlurView.alpha = 1
                    self.previewGestureRegionView.isHidden = false
                }
            }
        }
    }
    
    func animateSubmodeLabels() {
        self.textSubmodeLabel.alpha = 1
        self.boomerangSubmodeLabel.alpha = 1
        self.gridSubmodeLabel.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 6) {
            self.textSubmodeLabel.alpha = 0
            self.boomerangSubmodeLabel.alpha = 0
            self.gridSubmodeLabel.alpha = 0
        }
    }
    
    @objc private func userTappedExitButton() {
        self.navigationController?.pushViewController(PrimaryPageViewController.shared, animated: true)
    }
    
    @objc private func userTappedSubmodeButton(sender: UIButton) {
        switch sender {
        case self.textSubmodeButton:
            print("User tapped text submode button")
        case self.boomerangSubmodeButton:
            print("User tapped boomerang submode button")
        case self.gridSubmodeButton:
            print("User tapped grid submode button")
        default:
            print("User tapped submode expansion button")
        }
    }
    
    @objc private func userTappedFlashButton() {
        guard let currentModeIndex = self.photoOutput.supportedFlashModes.firstIndex(of: self.currentFlashMode) else {
            if self.photoOutput.supportedFlashModes.isEmpty {
                self.flashButton.isHidden = true
            } else {
                self.currentFlashMode = self.photoOutput.supportedFlashModes.first!
                self.flashButton.setBackgroundImage(self.flashModeIcons[self.currentFlashMode], for: .normal)
            }
            return
        }
        let newFlashModeIndex = (currentModeIndex + 1) % self.photoOutput.supportedFlashModes.count
        self.currentFlashMode = self.photoOutput.supportedFlashModes[newFlashModeIndex]
        self.flashButton.setBackgroundImage(self.flashModeIcons[self.currentFlashMode], for: .normal)
    }
    
    @objc private func userTappedSettingsButton() {
        print("The user tapped the settings button")
    }
    
    @objc private func userTappedCaptureButton() {
        print("The user tapped the capture button")
    }
    
    @objc private func userTappedPhotoLibraryButton() {
        if let contentController = self.parent as? ContentCreationViewController {
            contentController.scrollToChild(child: .photoLibrarySelect)
        }
    }
    
    @objc private func userTappedCameraToggleButton() {
        
        CATransaction.begin()
        self.cameraCaptureButton.isEnabled = false
        self.cameraSwapButton.isEnabled = false
        self.flashButton.layer.opacity = 0
        self.videoPreviewBlurView.layer.opacity = 1
        CATransaction.flush()
        CATransaction.commit()
        
        self.cameraTaskQueue.async {

            self.currentCameraPosition = (self.currentCameraPosition == .front) ? .back : .front
            self.captureSession.beginConfiguration()
            // Toggle the device input
            self.captureSession.removeInput((self.currentCameraPosition == .front) ? self.backCameraInput! : self.frontCameraInput!)
            self.captureSession.addInput((self.currentCameraPosition == .front) ? self.frontCameraInput! : self.backCameraInput!)
            
            // Add video mirroring if new camera position == .front
            DispatchQueue.main.async {
                if self.currentCameraPosition == .front {
                    if self.videoPreview.previewLayer.connection!.isVideoMirroringSupported && self.photoOutput.connection(with: .video)!.isVideoMirroringSupported {                        self.videoPreview.previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
                        self.videoPreview.previewLayer.connection!.isVideoMirrored = true
                        self.photoOutput.connection(with: .video)!.isVideoMirrored = true
                    }
                } else {
                    self.videoPreview.previewLayer.videoGravity = .resizeAspectFill
                    self.videoPreview.previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
                    self.videoPreview.previewLayer.connection!.isVideoMirrored = false
                    self.photoOutput.connection(with: .video)!.isVideoMirrored = false
                }
            }
            
            let showFlash = self.photoOutput.supportedFlashModes.firstIndex(of: .off) != nil

            self.captureSession.commitConfiguration()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, delay: 0) {
                    self.cameraCaptureButton.isEnabled = true
                    self.cameraSwapButton.isEnabled = true
                    self.flashButton.alpha = showFlash ? 1 : 0
                    self.flashButton.setBackgroundImage(self.flashModeIcons[.off], for: .normal)
                    self.currentFlashMode = .off
                    self.videoPreviewBlurView.alpha = 0
                }
            }
            }
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let videoPreviewViewTopSpacing = 161.0 / 3.0

    static let videoPreviewViewHeight = 2096.0 / 3.0
    
    static let exitButtonLeadingSpacing = 25.0
    static let exitButtonTopSpacing = 25.0
    static let exitButtonIconSize = CGSize.sqaure(size: 18)
    static let exitButtonIcon = UIImage(named: "ContentCreationPage/CameraCapture/exitIcon")!.withTintColor(.white).resizedTo(size: exitButtonIconSize)
    
    static var captureButtonImage: UIImage {
        let imageSize = CGSize.sqaure(size: screenWidth * 0.229)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            
            // Get the active context
            let context = UIGraphicsGetCurrentContext()!
            
            // Save graphics state to temporarily add clipping mask
            context.saveGState()
            
            // Create the clipping path
            let outerCircleRect = CGRect(origin: .zero, size: imageSize)
            context.addEllipse(in: outerCircleRect)
            let outerCircleClippingRect = outerCircleRect.insetBy(dx: imageSize.width * 0.05, dy: imageSize.width * 0.05)
            context.addEllipse(in: outerCircleClippingRect)
            context.clip(using: .evenOdd)
            
            // Paint the clipped-to area
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: outerCircleRect)
            
            // Remove clipping path
            context.restoreGState()
        
            // Fill the inner circle of the capture button image
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: outerCircleClippingRect.insetBy(dx: imageSize.width * 0.028 , dy: imageSize.width * 0.028))
        }
    }
    
    static let cameraSwapButtonTrailingSpacing = 11.0
    static let cameraSwapButtonTopSpacing = 65.0 / 3.0
    static let cameraSwapButtonSize = CGSize.sqaure(size: 132.0 / 3.0)
    static let cameraSwapButtonFillColor = UIColor(named: "ContentCreationPage/CameraCapture/cameraSwapButtonFillColor")!
    static let cameraSwapButtonIconSize = CGSize.sqaure(size: 22)
    static let cameraSwapButtonIcon = UIImage(named: "ContentCreationPage/CameraCapture/cameraSwapIcon")!.resizedTo(size: cameraSwapButtonIconSize).withTintColor(.white)
    
    static var cameraSwapButtonImage: UIImage {
        return UIGraphicsImageRenderer(size: cameraSwapButtonSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(cameraSwapButtonFillColor.cgColor)
            let circleRect = CGRect(origin: .zero, size: cameraSwapButtonSize)
            context.fillEllipse(in: circleRect)
            let iconSize = cameraSwapButtonIcon.size
            let iconRect = CGRect(x: circleRect.midX - (iconSize.width / 2), y: circleRect.midY - (iconSize.height / 2), width: iconSize.width, height: iconSize.height)
            cameraSwapButtonIcon.draw(in: iconRect)
        }
    }
    
    static let photoLibraryButtonSize = CGSize.sqaure(size: 102.0 / 3.0)
    static let photoLibraryIconCornerRadius = 9.0
    static let photoLibraryIconBorderWidth = 2.0
    static let photoLibraryButtonCenterYOffset = 131.0 / 3.0
    static let photoLibraryButtonCenterXOffset = 33.0
    
    static func photoLibraryButtonImage(forThumbnail thumbnail: UIImage) -> UIImage {
        return UIGraphicsImageRenderer(size: photoLibraryButtonSize).image{ _ in
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.white.cgColor)
            let borderRectPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: photoLibraryButtonSize), cornerRadius: photoLibraryIconCornerRadius)
            borderRectPath.fill()
            let scale = (photoLibraryButtonSize.width - (photoLibraryIconBorderWidth * 2)) / photoLibraryButtonSize.width
            borderRectPath.apply(CGAffineTransformMakeScale(scale, scale))
            borderRectPath.apply(CGAffineTransformMakeTranslation(photoLibraryIconBorderWidth, photoLibraryIconBorderWidth))
            context.addPath(borderRectPath.cgPath)
            context.clip()
            thumbnail.draw(in: borderRectPath.bounds)
        }
    }
    
    static let missingThumbnailIconSize = CGSize.sqaure(size: 24)
    static let missingThumbnailIcon = UIImage(named: "ContentCreationPage/CameraCapture/thumbnailMissingIcon")!.withTintColor(.white).resizedTo(size: missingThumbnailIconSize)
    
    // Unauthorized icon configurations
    static let unauthorizedIconTopSpacing = screenWidth * 0.4821
    static let unauthorizedIconSize = CGSize(width: screenWidth * 0.2085, height: screenWidth * 0.234)
    static let unauthorizedIconImage = UIImage(named: "ContentCreationPage/CameraAndMicrophoneAccessIcon")
    
    // Unauthorized Heading label configurations
    static let unauthorizedHeadingLabelTopSpacing = screenWidth * 0.0892
    static let unauthorizedHeadingLabelText = NSAttributedString(string: "Allow Instagram to access your\ncamera and microphone",attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0548, weight: .semibold),
        .paragraphStyle: NSParagraphStyle.centerAligned
    ])
    
    // camera microphone usage description label configurations
    static let cameraMicrophoneUsageDescriptionLabelTopSpacing = screenWidth * 0.069
    static let cameraMicrophoneUsageDescriptionLabelText = NSAttributedString(string: "This lets you share photos, record\nvideos and preview effects.", attributes: [
        .foregroundColor: UIColor.white.withAlphaComponent(0.65),
        .font: UIFont.systemFont(ofSize: screenWidth * 0.04459, weight: .regular),
        .paragraphStyle: NSParagraphStyle.centerAligned
    ])
    
    // Open settings button configurations
    static let openSettingsButtonTopSpacing = screenWidth * 0.158
    static let openSettingsButtonText = NSAttributedString(string: "Open Settings", attributes: [
        .foregroundColor: UIColor(named: "ContentCreationPage/EnableCameraMicrophoneAccessTextColor")!,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0477, weight: .semibold)
    ])
}
