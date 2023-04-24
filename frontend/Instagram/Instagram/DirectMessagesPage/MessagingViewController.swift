//
//  MessagingViewController.swift
//  InstagramClone
//
//  Created by brock davis on 10/19/22.
//

import UIKit

class MessagingViewController: UIViewController {
    
    private let headerView = UIView()
    private let backButton = UIButton()
    private let usernameButton = UIButton()
    private let otherAccountNotificationCountLabel = UILabel()
    private let ellipsisButton = UIButton()
    private let newDirectMessageButton = UIButton()
    private let directMessagesViewController: DirectMessagesViewController

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        let viewWidth = UIScreen.main.bounds.width
        self.directMessagesViewController = DirectMessagesViewController()
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .black
        
        // Add the header view
        self.headerView.backgroundColor = .black
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.headerView)
        NSLayoutConstraint.activate([
            self.headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.26)
        ])
        
        
        // Add the back chevron button
        self.backButton.setBackgroundImage(Configurations.backButtonImage, for: .normal)
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
        self.headerView.addSubview(self.backButton)
        NSLayoutConstraint.activate([
            self.backButton.leadingAnchor.constraint(equalTo: self.headerView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerView.topAnchor, constant: viewWidth * 0.195),
            self.backButton.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.08),
            self.backButton.heightAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.06)
        ])
        
        // Add the username button
        let attributedUsernameTitle = NSAttributedString(string: ActiveUser.loggedIn.first!.username, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: viewWidth / 17, weight: .bold)
        ])
        self.usernameButton.setAttributedTitle(attributedUsernameTitle, for: .normal)
        self.usernameButton.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.addSubview(self.usernameButton)
        NSLayoutConstraint.activate([
            self.usernameButton.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: viewWidth * 0.022),
            self.usernameButton.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor)
        ])
        
        // add the other account notification count label
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let notificationCountText = NSAttributedString(string: (ActiveUser.otherAccountNotificationsCount > 9) ? "9+" : String(ActiveUser.otherAccountNotificationsCount), attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: viewWidth / 28.8, weight: .semibold),
            .paragraphStyle: paragraphStyle
        ])
        self.otherAccountNotificationCountLabel.attributedText = notificationCountText
        self.otherAccountNotificationCountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.otherAccountNotificationCountLabel.backgroundColor = UIColor(named: "OtherAccountNotificationCountBackgroundColor")!
        self.otherAccountNotificationCountLabel.layer.cornerRadius = viewWidth * 0.021
        self.otherAccountNotificationCountLabel.layer.masksToBounds = true
        self.headerView.addSubview(self.otherAccountNotificationCountLabel)
        NSLayoutConstraint.activate([
            self.otherAccountNotificationCountLabel.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor),
            self.otherAccountNotificationCountLabel.leadingAnchor.constraint(equalTo: self.usernameButton.trailingAnchor, constant: viewWidth * 0.01),
            self.otherAccountNotificationCountLabel.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.055),
            self.otherAccountNotificationCountLabel.heightAnchor.constraint(equalTo: self.otherAccountNotificationCountLabel.widthAnchor, multiplier: 0.8)
        ])
        
        // Add the create DM Button
        self.newDirectMessageButton.setBackgroundImage(UIImage(named: "CreateDMIcon")!.withTintColor(.white), for: .normal)
        self.newDirectMessageButton.addTarget(self, action: #selector(self.newDMButtonTapped), for: .touchUpInside)
        self.newDirectMessageButton.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.addSubview(self.newDirectMessageButton)
        NSLayoutConstraint.activate([
            self.newDirectMessageButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -viewWidth * 0.04),
            self.newDirectMessageButton.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor),
            self.newDirectMessageButton.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.0575),
            self.newDirectMessageButton.heightAnchor.constraint(equalTo: self.newDirectMessageButton.widthAnchor)
        ])
        
        // Add the ellipsis button
        self.ellipsisButton.setBackgroundImage(Configurations.ellipsisButtonImage, for: .normal)
        self.ellipsisButton.addTarget(self, action: #selector(self.ellipsisButtonTapped), for: .touchUpInside)
        self.ellipsisButton.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.addSubview(self.ellipsisButton)
        NSLayoutConstraint.activate([
            self.ellipsisButton.trailingAnchor.constraint(equalTo: self.newDirectMessageButton.leadingAnchor, constant: -viewWidth * 0.0745),
            self.ellipsisButton.centerYAnchor.constraint(equalTo: self.newDirectMessageButton.centerYAnchor),
            self.ellipsisButton.widthAnchor.constraint(equalTo: self.headerView.widthAnchor, multiplier: 0.0344),
            self.ellipsisButton.heightAnchor.constraint(equalTo: self.ellipsisButton.widthAnchor)
        ])
        
        self.addChild(self.directMessagesViewController)
        let childView = self.directMessagesViewController.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            childView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor)
        ])
        self.directMessagesViewController.didMove(toParent: self)
    }
    
    @objc private func backButtonTapped() {
        self.view.endEditing(true)
        PrimaryPageViewController.shared.transitionTo(page: .tabBar)
    }
    
    @objc private func newDMButtonTapped() {
        print("New DM button tapped")
    }
    
    @objc private func ellipsisButtonTapped() {
        print("ellipsis button tapped")
    }
}

private struct Configurations {
    
    static var viewWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var backButtonImage: UIImage {
        let imageSize = CGSize(width: viewWidth * 0.08, height: viewWidth * 0.06)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            let iconRect = CGRect(x: imageSize.width - (imageSize.height * 0.75), y: 0, width: imageSize.height * 0.75, height: imageSize.height)
            UIImage(systemName: "chevron.left")!.withTintColor(.white).draw(in: iconRect)
        }
    }
    
    static var ellipsisButtonImage: UIImage {
        let imageSize = CGSize(width: viewWidth * 0.0344, height: viewWidth * 0.0344)
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            let ellipsisRect = CGRect(x: 0, y: (imageSize.height / 2) - ((imageSize.width * 0.3) / 2), width: imageSize.width, height: imageSize.width * 0.3)
            UIImage(named: "EllipsisIcon")!.withTintColor(.white).draw(in: ellipsisRect)
        }
    }
}
