//
//  DirectMessagesSearchBar.swift
//  InstagramClone
//
//  Created by brock davis on 10/20/22.
//

import UIKit

class DirectMessagesSearchBar: UIView {
    
    private let searchIconView = UIImageView(image: UIImage(named: "DMSearchIcon")!)
    let textField = UITextField()

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        let viewWidth = self.bounds.width
        let searchIconSideLength = viewWidth * 0.043
        self.searchIconView.frame = CGRect(x: viewWidth * 0.0335, y: self.bounds.midY - (searchIconSideLength / 2), width: searchIconSideLength, height: searchIconSideLength)
        let textFieldHeight = self.bounds.height * 0.85
        let textFieldXOrigin = self.searchIconView.frame.maxX + (viewWidth * 0.025)
        self.textField.frame = CGRect(x: textFieldXOrigin, y: self.bounds.midY - (textFieldHeight / 2), width: self.bounds.width - textFieldXOrigin , height: textFieldHeight)
        super.layoutSubviews()
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor(named: "DMSearchBarColor")!
        
        // add the subviews
        self.addSubview(self.searchIconView)
        self.addSubview(self.textField)
        
        // Configure text field
        self.textField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ])
        self.textField.clearButtonMode = .whileEditing
        self.textField.defaultTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.9),
            .font: UIFont.systemFont(ofSize: UIScreen.main.bounds.width / 20.8, weight: .regular)
        ]
        self.textField.tintColor = .white.withAlphaComponent(0.6)
        self.textField.keyboardAppearance = .dark
        self.textField.keyboardType = .namePhonePad
    }

}
