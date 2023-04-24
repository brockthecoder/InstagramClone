//
//  DirectMessageHiddenRequestsCollectionViewCell.swift
//  InstagramClone
//
//  Created by brock davis on 11/5/22.
//

import UIKit

class DirectMessageHiddenRequestsCollectionViewCell: UICollectionViewCell {
    
    private let hiddenRequestsIconView = UIImageView()
    private let hiddenRequestsLabel = UILabel()
    private let hiddenRequestsCountLabel = UILabel()
    private let showRequestsButton = UIButton()
    
    var hiddenRequestsCount: Int = 0 {
        didSet {
            self.hiddenRequestsCountLabel.attributedText = NSAttributedString(string: String(self.hiddenRequestsCount), attributes: Configurations.hiddenRequestsCountLabelTextAttributes)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        
        // Set up the background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        self.backgroundView = backgroundView
        
        // Set up the selected background view
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Configurations.selectedBackgroundViewBackgroundColor
        self.selectedBackgroundView = selectedBackgroundView
        
        // Set up the hidden requests icon view
        self.hiddenRequestsIconView.translatesAutoresizingMaskIntoConstraints = false
        self.hiddenRequestsIconView.image = Configurations.hiddenRequestsIconImage
        self.contentView.addSubview(self.hiddenRequestsIconView)
        NSLayoutConstraint.activate([
            self.hiddenRequestsIconView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Configurations.hiddenRequestsIconLeadingSpacing),
            self.hiddenRequestsIconView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.hiddenRequestsIconView.widthAnchor.constraint(equalToConstant: Configurations.hiddenRequestsIconSize.width),
            self.hiddenRequestsIconView.heightAnchor.constraint(equalToConstant: Configurations.hiddenRequestsIconSize.height)
        ])
        
        // Set up the hidden requests label
        self.hiddenRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.hiddenRequestsLabel.attributedText = Configurations.hiddenRequestsLabelText
        self.contentView.addSubview(self.hiddenRequestsLabel)
        NSLayoutConstraint.activate([
            self.hiddenRequestsLabel.leadingAnchor.constraint(equalTo: self.hiddenRequestsIconView.trailingAnchor, constant: Configurations.hiddenRequestsLabelLeadingSpacing),
            self.hiddenRequestsLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        // Set up the show requests button
        self.showRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        self.showRequestsButton.setBackgroundImage(Configurations.showRequestsButtonBackgroundImage, for: .normal)
        self.showRequestsButton.addTarget(self, action: #selector(self.showRequestsButtonTapped), for: .touchUpInside)
        self.contentView.addSubview(self.showRequestsButton)
        NSLayoutConstraint.activate([
            self.showRequestsButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.showRequestsButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -Configurations.showRequestsButtonTrailingSpacing),
            self.showRequestsButton.widthAnchor.constraint(equalToConstant: Configurations.showRequestsButtonSize.width),
            self.showRequestsButton.heightAnchor.constraint(equalToConstant: Configurations.showRequestsButtonSize.height)
        ])
        
        // Set up the hidden requests count label
        self.hiddenRequestsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.hiddenRequestsCountLabel.attributedText = NSAttributedString(string: "0", attributes: Configurations.hiddenRequestsCountLabelTextAttributes)
        self.contentView.addSubview(self.hiddenRequestsCountLabel)
        NSLayoutConstraint.activate([
            self.hiddenRequestsCountLabel.trailingAnchor.constraint(equalTo: self.showRequestsButton.leadingAnchor, constant: -Configurations.hiddenRequestsCountLabelTrailingSpacing),
            self.hiddenRequestsCountLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
    
    @objc private func showRequestsButtonTapped() {
        
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    static let selectedBackgroundViewBackgroundColor = UIColor(named: "DMCellSelectedBackgroundColor")!
    
    // Hidden Requests Icon View Configurations
    static let hiddenRequestsIconLeadingSpacing = screenWidth * 0.037
    static let hiddenRequestsIconSize = CGSize.sqaure(size: screenWidth * 0.153)
    static let hiddenRequestsIconImage: UIImage = UIGraphicsImageRenderer(size: hiddenRequestsIconSize).image { _ in
        let context = UIGraphicsGetCurrentContext()!
        let borderRect = CGRect(origin: .zero, size: hiddenRequestsIconSize).insetBy(dx: 2, dy: 2)
        context.addEllipse(in: borderRect)
        UIColor(named: "HiddenRequestsOutlineBorderColor")!.setStroke()
        context.setLineWidth(0.6)
        context.strokePath()
        
        let iconRectSize = borderRect.size.applying(CGAffineTransformMakeScale(0.5, 0.5))
        let iconRect = CGRect(x: borderRect.midX - (iconRectSize.width / 2), y: borderRect.midY - (iconRectSize.height / 2), width: iconRectSize.width, height: iconRectSize.height)
        UIImage(named: "HiddenRequestsIcon")!.withTintColor(.white.withAlphaComponent(0.9)).draw(in: iconRect)
    }
    
    // Hidden Requests Label Configurations
    static let hiddenRequestsLabelLeadingSpacing = screenWidth * 0.0352
    static let hiddenRequestsLabelText = NSAttributedString(string: "Hidden Requests", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.04, weight: .regular)
    ])
    
    // Show Requests Button Configurations
    static let showRequestsButtonTrailingSpacing = screenWidth * 0.0497
    static let showRequestsButtonSize = CGSize(width: screenWidth * 0.031, height: screenWidth * 0.042)
    static let showRequestsButtonBackgroundImage = UIImage(systemName: "chevron.right")!.withTintColor(.white.withAlphaComponent(0.6)).resizedTo(size: showRequestsButtonSize)
    
    // Hidden Requests Count Label Configurations
    static let hiddenRequestsCountLabelTrailingSpacing = screenWidth * 0.04
    static let hiddenRequestsCountLabelTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white.withAlphaComponent(0.6),
        .font: UIFont.systemFont(ofSize: screenWidth * 0.042, weight: .regular)
    ]
}
