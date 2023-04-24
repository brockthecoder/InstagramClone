//
//  ProfileBioView.swift
//  InstagramClone
//
//  Created by brock davis on 11/7/22.
//

import UIKit

class ProfileBioView: UIView {
    
    private let manager = NSLayoutManager()
    private let container = NSTextContainer()
    private var drawingSize: CGSize = .zero
    private let text = NSTextStorage()

    var biography: String? {
        didSet {
            guard let biography else { return }
            self.text.deleteCharacters(in: NSMakeRange(0, self.text.length))
            self.text.append(NSAttributedString(string: biography, attributes: Configurations.regularTextAttributes))
            NSRegularExpression.hashtagMentionFinder.enumerateMatches(in: self.text.string, range: NSMakeRange(0, self.text.string.count)) { result, _, _ in
                guard let result else { return }
                let range = result.range
                self.text.addAttributes(Configurations.entityTextAttributes, range: range)
            }
            self.drawingSize = self.manager.boundingRect(forGlyphRange: NSMakeRange(0, self.manager.numberOfGlyphs), in: self.container).size
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.drawingSize
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        self.contentMode = .redraw
        
        self.text.addLayoutManager(self.manager)
        self.manager.addTextContainer(self.container)
        self.container.size = Configurations.containerSize
        self.container  .lineFragmentPadding = 0
    
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.setFill()
        UIBezierPath(rect: rect).fill()
        
        let glyphRange = NSMakeRange(0, manager.numberOfGlyphs)
        self.manager.drawBackground(forGlyphRange: glyphRange, at: .zero)
        self.manager.drawGlyphs(forGlyphRange: glyphRange, at: .zero)
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let containerSize = CGSize(width: screenWidth * 0.9, height: 400)
    
    static let font = UIFont.systemFont(ofSize: screenWidth * 0.0408, weight: .regular)
    
    static let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0.7
        return style
    }()
    
    static let regularTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/biographyView/textColor")!,
        .font: font,
        .paragraphStyle: paragraphStyle
    ]
    
    static let entityTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor(named: "ProfilePage/Details/biographyView/entityTextColor")!,
        .font: font
    ]
}
