//
//  DirectMessagesCollectionHeaderView.swift
//  InstagramClone
//
//  Created by brock davis on 10/20/22.
//

import UIKit

class DirectMessagesCollectionHeaderView: UICollectionReusableView, UITextFieldDelegate {
    
    private let searchBar = DirectMessagesSearchBar()
    private let filterButton = UIButton()
    private let cancelButton = UIButton()
    private let primaryButton = UIButton()
    private let generalButton = UIButton()
    private let requestsButton = UIButton()
    var delegate: DirectMessagesHeaderViewDelegate?
    fileprivate static let dmBlue = UIColor(named: "DMBlue")!
    
        
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let viewWidth = UIScreen.main.bounds.width
        
        // Add the custom search bar
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.searchBar.layer.cornerRadius = viewWidth * 0.0265
        self.searchBar.textField.delegate = self
        self.addSubview(self.searchBar)
        NSLayoutConstraint.activate([
            self.searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: viewWidth * 0.0344),
            self.searchBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.797),
            self.searchBar.heightAnchor.constraint(equalTo: self.searchBar.widthAnchor, multiplier: 0.12),
            self.searchBar.topAnchor.constraint(equalTo: self.topAnchor, constant: viewWidth * 0.026)
        ])
        
        // Add the filter button
        let filterTitle = NSAttributedString(string: "Filter", attributes: [
            .foregroundColor: UIColor(named: "DMBlue")!,
            .font: UIFont.systemFont(ofSize: viewWidth / 25, weight: .semibold)
        ])
        self.filterButton.setAttributedTitle(filterTitle, for: .normal)
        self.filterButton.translatesAutoresizingMaskIntoConstraints = false
        self.filterButton.addTarget(self, action: #selector(self.filterButtonTapped), for: .touchUpInside)
        self.addSubview(self.filterButton)
        NSLayoutConstraint.activate([
            self.filterButton.centerYAnchor.constraint(equalTo: self.searchBar.centerYAnchor),
            self.filterButton.leadingAnchor.constraint(equalTo: self.searchBar.trailingAnchor, constant: viewWidth * 0.0287)
        ])
        
        // Add the cancel button
        let cancelTitle = NSAttributedString(string: "Cancel", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.9),
            .font: UIFont.systemFont(ofSize: viewWidth / 23, weight: .regular)
        ])
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cancelButton)
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped), for: .touchUpInside)
        self.cancelButton.setAttributedTitle(cancelTitle, for: .normal)
        self.cancelButton.isHidden = true
        NSLayoutConstraint.activate([
            self.cancelButton.leadingAnchor.constraint(equalTo: self.searchBar.trailingAnchor, constant: viewWidth * 0.032),
            self.cancelButton.centerYAnchor.constraint(equalTo: self.searchBar.centerYAnchor)
        ])
        
        
        // Add the primary tab button
        self.primaryButton.translatesAutoresizingMaskIntoConstraints = false
        self.primaryButton.setBackgroundImage(Configurations.tabImage(forMessageGrouping: .primary, isSelected: false, unreadCount: ActiveUser.loggedIn.first!.messengerNotifications.unseenPrimaryMessages), for: .normal)
        self.primaryButton.setBackgroundImage(Configurations.tabImage(forMessageGrouping: .primary, isSelected: true, unreadCount: ActiveUser.loggedIn.first!.messengerNotifications.unseenPrimaryMessages), for: .selected)
        self.primaryButton.isSelected = true
        self.primaryButton.addTarget(self, action: #selector(self.tabTapped(tab:)), for: .touchUpInside)
        self.addSubview(self.primaryButton)
        NSLayoutConstraint.activate([
            self.primaryButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.primaryButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.33),
            self.primaryButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 3),
            self.primaryButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -viewWidth * 0.02)
        ])
        
        // Add the general tab button
        self.generalButton.translatesAutoresizingMaskIntoConstraints = false
        self.generalButton.addTarget(self, action: #selector(self.tabTapped(tab:)), for: .touchUpInside)
        self.generalButton.setBackgroundImage(Configurations.tabImage(forMessageGrouping: .general, isSelected: false, unreadCount: ActiveUser.loggedIn.first!.messengerNotifications.unseenGeneralMessages), for: .normal)
        self.generalButton.setBackgroundImage(Configurations.tabImage(forMessageGrouping: .general, isSelected: true, unreadCount: ActiveUser.loggedIn.first!.messengerNotifications.unseenGeneralMessages), for: .selected)
        self.addSubview(self.generalButton)
        NSLayoutConstraint.activate([
            self.generalButton.leadingAnchor.constraint(equalTo: self.primaryButton.trailingAnchor),
            self.generalButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.33),
            self.generalButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 3),
            self.generalButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -viewWidth * 0.02)
        ])
        
        // Add the requests tab button
        self.requestsButton.translatesAutoresizingMaskIntoConstraints = false
        self.requestsButton.addTarget(self, action: #selector(self.tabTapped(tab:)), for: .touchUpInside)
        self.requestsButton.setBackgroundImage(Configurations.tabImage(forMessageGrouping: .requests, isSelected: false, unreadCount: ActiveUser.loggedIn.first!.messengerNotifications.unseenRequests), for: .normal)
        self.addSubview(self.requestsButton)
        NSLayoutConstraint.activate([
            self.requestsButton.leadingAnchor.constraint(equalTo: self.generalButton.trailingAnchor),
            self.requestsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.requestsButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 3),
            self.requestsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -viewWidth * 0.02)
        ])
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.headerView(self, didStartSearchWith: textField)
        self.cancelButton.isHidden = false
        self.filterButton.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.cancelButton.isHidden = true
        self.filterButton.isHidden = false
        self.searchBar.textField.text = ""
        self.delegate?.headerView(self, didEndSearchWith: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @objc private func filterButtonTapped() {
        print("Filter button tapped")
    }
    
    @objc private func tabTapped(tab: UIButton) {
        if tab == self.primaryButton {
            self.primaryButton.isSelected = true
            self.generalButton.isSelected = false
            self.requestsButton.isSelected = false
            self.delegate?.headerView(self, didSelectMessageGrouping: .primary)
        } else if tab == self.generalButton {
            self.primaryButton.isSelected = false
            self.generalButton.isSelected = true
            self.requestsButton.isSelected = false
            self.delegate?.headerView(self, didSelectMessageGrouping: .general)
        } else {
            self.delegate?.headerViewSelectedRequestsTab(self)
        }
    }
    
    @objc func cancelButtonTapped() {
        self.searchBar.textField.endEditing(true)
    }
}

private struct Configurations {
    
    private static let dividerBackgroundColor = UIColor(named: "DMDividerBackgroundColor")!
    private static let dmBlue = UIColor(named: "DMBlue")!
    
    private static var viewWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static func tabImage(forMessageGrouping messageGrouping: MessageGrouping, isSelected: Bool = false, unreadCount: Int? = nil) -> UIImage {
        let tabSize = CGSize(width: viewWidth / 3, height: viewWidth * 0.13)
        return UIGraphicsImageRenderer(size: tabSize).image{ _ in
            let context = UIGraphicsGetCurrentContext()!
            
            let tabText = {
                switch messageGrouping {
                case .primary:
                    return "Primary"
                case .general:
                    return "General"
                default:
                    if let unreadCount, unreadCount > 0 {
                        return unreadCount > 98 ? "99+ Requests" : "Requests (\(unreadCount))"
                    }
                    return "Requests"
                }
            }()
            
            var textColor: UIColor
            if messageGrouping == .requests, let unreadCount, unreadCount > 0 { textColor = dmBlue }
            else if isSelected { textColor = .white }
            else { textColor = .white.withAlphaComponent(0.65) }
            
            let attributedTabTitle = NSAttributedString(string: tabText, attributes: [
                .foregroundColor: textColor,
                .expansion: -0.1,
                .font: UIFont.systemFont(ofSize: viewWidth / 22.5, weight: .semibold)
            ])
            
            let tabTitleSize = attributedTabTitle.size()
            let tabTitleRect = CGRect(x: (tabSize.width / 2) - (tabTitleSize.width / 2), y: (tabSize.height / 2) - (tabTitleSize.height / 2), width: tabTitleSize.width, height: tabTitleSize.height)
            attributedTabTitle.draw(in: tabTitleRect)
            
            if messageGrouping != .requests, let unreadCount, unreadCount > 0 {
                context.setFillColor(DirectMessagesCollectionHeaderView.dmBlue.cgColor)
                context.fillEllipse(in: CGRect(x: tabTitleRect.maxX + tabSize.width / 30, y: tabTitleRect.midY - tabSize.height / 40, width: 4.5, height: 4.5))
            }
            
            context.setFillColor(isSelected ? UIColor.white.cgColor : Self.dividerBackgroundColor.cgColor)
            let underLineHeight = isSelected ? (tabSize.height / 30) : (tabSize.height / 70)
            context.fill([CGRect(x: 0, y: tabSize.height - underLineHeight, width: tabSize.width, height: underLineHeight)])
        }
    }
}

protocol DirectMessagesHeaderViewDelegate {
    
    func headerView(_ view: DirectMessagesCollectionHeaderView, didStartSearchWith textField: UITextField)
    
    func headerView(_ view: DirectMessagesCollectionHeaderView, didEndSearchWith textField: UITextField)
    
    func headerView(_ view: DirectMessagesCollectionHeaderView, didSelectMessageGrouping messageGrouping: MessageGrouping)
    
    func headerViewSelectedRequestsTab(_ view: DirectMessagesCollectionHeaderView)
}
