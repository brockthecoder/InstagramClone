//
//  DirectMessagesRequestCollectionViewHeader.swift
//  InstagramClone
//
//  Created by brock davis on 11/4/22.
//

import UIKit

class DirectMessagesRequestCollectionViewHeader: UICollectionReusableView {
    
    private let detailsLabel = UILabel()
    private let detailsLabelDivider = UIView()
    private let requestsFilterButton = UIButton()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up the details label
        self.detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailsLabel.numberOfLines = 2
        self.detailsLabel.attributedText = Configurations.detailsLabelText
        self.detailsLabel.backgroundColor = Configurations.detailsLabelBackgroundColor
        self.addSubview(self.detailsLabel)
        NSLayoutConstraint.activate([
            self.detailsLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.detailsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.detailsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.detailsLabel.heightAnchor.constraint(equalToConstant: Configurations.detailsLabelHeight)
        ])
        
        // Set up the details label divider
        self.detailsLabelDivider.translatesAutoresizingMaskIntoConstraints = false
        self.detailsLabelDivider.backgroundColor = Configurations.detailsLabelDividerBackgroundColor
        self.detailsLabel.addSubview(self.detailsLabelDivider)
        NSLayoutConstraint.activate([
            self.detailsLabelDivider.leadingAnchor.constraint(equalTo: self.detailsLabel.leadingAnchor),
            self.detailsLabelDivider.trailingAnchor.constraint(equalTo: self.detailsLabel.trailingAnchor),
            self.detailsLabelDivider.topAnchor.constraint(equalTo: self.detailsLabel.bottomAnchor),
            self.detailsLabelDivider.heightAnchor.constraint(equalToConstant: Configurations.detailsLabelDividerHeight)
        ])
        
        // Set up the request filter button
        self.requestsFilterButton.translatesAutoresizingMaskIntoConstraints = false
        self.requestsFilterButton.setBackgroundImage(Configurations.requestFilterButtonBackgroundImage, for: .normal)
        self.requestsFilterButton.addTarget(self, action: #selector(self.userTappedRequestsFilterButton), for: .touchUpInside)
        self.addSubview(self.requestsFilterButton)
        NSLayoutConstraint.activate([
            self.requestsFilterButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.requestsFilterButton.topAnchor.constraint(equalTo: self.detailsLabel.bottomAnchor, constant: Configurations.requestsFilterButtonTopSpacing),
            self.requestsFilterButton.widthAnchor.constraint(equalToConstant: Configurations.requestsFilterButtonWidth),
            self.requestsFilterButton.heightAnchor.constraint(equalToConstant: Configurations.requestsFilterButtonHeight)
        ])
    }
    
    @objc private func userTappedRequestsFilterButton() {
        print("request filter button tapped")
    }
        
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    // Details label Configuration
    static let detailsLabelHeight = screenWidth * 0.161
    static let detailsLabelBackgroundColor = UIColor(named: "DetailsLabelBackgroundColor")!
    static let detailsLabelText: NSAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        return NSAttributedString(string: "Open a chat to get more info about who's messaging\nyou. They won't know you've seen it until you accept.", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: screenWidth * 0.034, weight: .regular),
            .tracking: 0.1
        ])
    }()
    
    // Details label divider Configuration
    static let detailsLabelDividerHeight = screenWidth * 0.001
    static let detailsLabelDividerBackgroundColor = UIColor(named: "DMRequestsPageHeaderDividerColor")!
    
    // Requests filter button Configuration
    static let requestsFilterButtonTopSpacing = screenWidth * 0.0244
    static let requestsFilterButtonWidth = screenWidth * 0.966
    static let requestsFilterButtonHeight = screenWidth * 0.089
    static let requestsFilterButtonBoderColor = UIColor(named: "FilterButtonBorderColor")!
    static let requestsFilterButtonText = NSAttributedString(string: "All requests", attributes: [
        .foregroundColor: UIColor.white,
        .font: UIFont.systemFont(ofSize: screenWidth * 0.0352, weight: .medium)
    ])
    static let requestFilterButtonIcon = UIImage(named: "DMRequestsFilterIcon")!
    static let requestFilterButtonIconTrailingSpacing = screenWidth * 0.047
    static let requestFilterButtonIconSize = CGSize.sqaure(size: screenWidth * 0.038)
    static let requestFilterButtonBackgroundImage: UIImage = {
        let imageSize = CGSize(width: requestsFilterButtonWidth, height: requestsFilterButtonHeight)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            let context = UIGraphicsGetCurrentContext()!
            let roundedRectPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: imageSize), cornerRadius: imageSize.width * 0.009).cgPath
            requestsFilterButtonBoderColor.setStroke()
            context.addPath(roundedRectPath)
            context.setLineWidth(1.15)
            context.strokePath()
            
            let textSize = requestsFilterButtonText.size()
            let textRect = CGRect(x: (imageSize.width / 2) - (textSize.width / 2), y: (imageSize.height / 2) - (textSize.height / 2), width: textSize.width, height: textSize.height)
            requestsFilterButtonText.draw(in: textRect)
            
            let iconRect = CGRect(x: imageSize.width - requestFilterButtonIconTrailingSpacing - (requestFilterButtonIconSize.width / 2), y: (imageSize.height / 2) - (requestFilterButtonIconSize.height / 2), width: requestFilterButtonIconSize.width, height: requestFilterButtonIconSize.height)
            requestFilterButtonIcon.draw(in: iconRect)
        }
    }()
}
