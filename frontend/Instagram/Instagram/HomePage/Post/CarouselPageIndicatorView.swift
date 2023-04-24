//
//  CarouselPageIndicatorView.swift
//  Instagram
//
//  Created by brock davis on 3/7/23.
//

import UIKit

class CarouselPageIndicatorView: UIView {
    
    private var dotLayers: [CAShapeLayer] {
        self.layer.sublayers as! [CAShapeLayer]
    }
    
    var numberOfPages: Int = 0 {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            CATransaction.setDisableActions(true)
            self.dotLayers[oldValue].fillColor =  Configurations.unselectedDotFillColor.cgColor
            self.dotLayers[currentPage].fillColor = Configurations.selectedDotFillColor.cgColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var dotOrigin: CGPoint = .zero
        if self.numberOfPages <= 5 {
            for dotLayer in self.dotLayers {
                dotLayer.frame = CGRect(origin: dotOrigin, size: Configurations.dotSize)
                dotOrigin.x += (Configurations.dotSize.width + Configurations.interDotSpacing)
            }
        }
        
        // TODO -> Add support for 6-10 pages
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: (CGFloat(self.numberOfPages)  * Configurations.dotSize.width) + (CGFloat(self.numberOfPages - 1) * Configurations.interDotSpacing), height: Configurations.dotSize.height)
    }
    
    init() {
        super.init(frame: .zero)
        self.clipsToBounds = true
        for _ in 0...10 {
            let dotLayer = CAShapeLayer()
            dotLayer.path = CGPath(ellipseIn: CGRect(origin: .zero, size: Configurations.dotSize), transform: nil)
            dotLayer.fillColor = Configurations.unselectedDotFillColor.cgColor
            self.layer.addSublayer(dotLayer)
        }
    }
}

private struct Configurations {
    static let dotSize = CGSize.sqaure(size: 6)
    
    static let interDotSpacing: CGFloat = 4.0
    
    static let unselectedDotFillColor = UIColor(named: "HomePage/Feed/Post/CarouselPageIndicator/unselectedFillColor")!
    
    static let selectedDotFillColor = UIColor(named: "HomePage/Feed/Post/CarouselPageIndicator/currentFillColor")!
}
