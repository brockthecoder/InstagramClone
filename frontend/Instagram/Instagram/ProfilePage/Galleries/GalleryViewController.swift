//
//  GalleryViewController.swift
//  InstagramClone
//
//  Created by brock davis on 1/22/23.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let collectionView: UICollectionView
    
    var profileContentHeight: CGFloat = 0 {
        didSet {
            self.collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: profileContentHeight, left: 0, bottom: 0, right: 0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(layout: UICollectionViewLayout) {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(self.collectionView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.view.topAnchor),
                $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                $0.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

}
