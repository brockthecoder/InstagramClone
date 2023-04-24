//
//  CaptureModeSelectionView.swift
//  InstagramClone
//
//  Created by brock davis on 10/17/22.
//

import UIKit

class CaptureModeSelectionView: UIView {

    private let modeLabels: [UILabel]
    private let attributedModeStrings: [(unselected: NSAttributedString, selected: NSAttributedString)]
    private let dragRecognizer = UIPanGestureRecognizer()
    private let grayBackgroundColor = UIColor(named: "ContentCreationPage/CaptureModeSelectionGrayBackgroundColor")!
    
    var selectedIndex: Int = 1
    
    var backgroundType: CaptureModeSelectionViewBackgroundType = .transparent {
        didSet {
            switch self.backgroundType {
            case .transparent:
                self.backgroundColor = .clear
            case .solidGray:
                self.backgroundColor = self.grayBackgroundColor
            }
        }
    }
    

    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(modes: [String] = ["POST", "STORY", "LIVE"]) {
        
        let textFontSize = UIScreen.main.bounds.width * 0.0418
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
    
        var modeLabels: [UILabel] = []
        var attributedModeStrings: [(unselected: NSAttributedString, selected: NSAttributedString)] = []
        
        for (ix, mode) in modes.enumerated() {
            let selectedText = NSAttributedString(string: mode, attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: textFontSize, weight: .semibold),
                .expansion: 0.02,
                .kern: 0.7,
                .paragraphStyle: paragraphStyle
            ])
            
            let unselectedText = NSAttributedString(string: mode, attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.4),
                .font: UIFont.systemFont(ofSize: textFontSize, weight: .regular),
                .kern: 0.7,
                .paragraphStyle: paragraphStyle
            ])
            attributedModeStrings.append((unselectedText, selectedText))
            
            let label = UILabel()
            label.attributedText = (ix == self.selectedIndex) ? selectedText : unselectedText
            modeLabels.append(label)
        }
        self.modeLabels = modeLabels
        self.attributedModeStrings = attributedModeStrings
       
        super.init(frame: .zero)
        for label in modeLabels {
            self.addSubview(label)
        }

        self.dragRecognizer.addTarget(self, action: #selector(self.userDragged(recognizer:)))
        self.dragRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(self.dragRecognizer)
    }
    
    override func layoutSubviews() {
        let interLabelSpacing = self.bounds.width * 0.033
        let selectedLabel = self.modeLabels[self.selectedIndex]
        selectedLabel.bounds = CGRect(origin: .zero, size: selectedLabel.intrinsicContentSize)
        selectedLabel.center = self.bounds.center
        let labelSlices = self.modeLabels.split(separator: selectedLabel)
        let leftLabels = Array(labelSlices.first!)
        let rightLabels = Array(labelSlices.last!)
        
        var lastCenter = selectedLabel.center
        var lastMidX = selectedLabel.bounds.midX
        for label in leftLabels.reversed() {
            label.bounds = CGRect(origin: .zero, size: label.intrinsicContentSize)
            let xTranslation = -lastMidX - interLabelSpacing - label.bounds.midX
            label.center = lastCenter.applying(CGAffineTransformMakeTranslation(xTranslation, 0))
            lastCenter = label.center
            lastMidX = label.bounds.midX
        }
        lastCenter = selectedLabel.center
        lastMidX = selectedLabel.bounds.midX
        for label in rightLabels {
            label.bounds = CGRect(origin: .zero, size: label.intrinsicContentSize)
            let xTranslation = lastMidX + interLabelSpacing + label.bounds.midX
            label.center = lastCenter.applying(CGAffineTransformMakeTranslation(xTranslation, 0))
            lastCenter = label.center
            lastMidX = label.bounds.midX
        }
    }
    
    @objc func userDragged(recognizer: UIPanGestureRecognizer) {
        
    }
}

enum CaptureModeSelectionViewBackgroundType {
    case transparent
    case solidGray
}

protocol CaptureModeSelectionViewDelegate {
    func captureModeSelection(_ view: CaptureModeSelectionView, didSelectModeAtIndex: Int)
    
    func captureModeSelection(_ view: CaptureModeSelectionView, backgroundTypeForModeAtIndex: Int) -> CaptureModeSelectionViewBackgroundType
}
