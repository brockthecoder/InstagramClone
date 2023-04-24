//
//  AddCommentTableViewCell.swift
//  Instagram
//
//  Created by brock davis on 3/20/23.
//

import UIKit

class AddCommentTableViewCell: UITableViewCell {
    
    private let pfpView = ProfilePictureView(outlineWidth: 0)
    private let label = UILabel()

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.pfpView.storyStatus = .none
        self.contentView.addSubview(self.pfpView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                $0.widthAnchor.constraint(equalToConstant: Configurations.pfpViewSize.width),
                $0.heightAnchor.constraint(equalToConstant: Configurations.pfpViewSize.height)
            ])
        }
        
        self.label.attributedText = Configurations.addCommentText
        self.contentView.addSubview(self.label) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.pfpView.trailingAnchor, constant: Configurations.addCommentTextLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.pfpView.centerYAnchor)
            ])
        }
    }
    
}

private struct Configurations {
    
    static let addCommentText = NSAttributedString(string: "Add a comment...", attributes: [
        .foregroundColor: UIColor(named: "HomePage/Feed/Post/addCommentTextColor")!,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
    ])
    
    static let addCommentTextLeadingConstant: CGFloat = 8.0
    
    static let pfpViewSize = CGSize.sqaure(size: 26)
    
    static let rowSpacing: CGFloat = 3.0
}
