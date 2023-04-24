//
//  PostTopCommentsView.swift
//  Instagram
//
//  Created by brock davis on 3/19/23.
//

import UIKit

class PostTopCommentsView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    
    var topComments: [FeedPostComment] = [] {
        didSet {
            if self.window != nil {
                self.reloadData()
            }
        }
    }
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    private let topCommentCellID = "topCommentCell"
    private let addCommentCellID = "addCommentCell"
    private let labelTag = 333
    private let likeButtonTag = 777
    private let pfpViewTag = 444
    private let spacerViewTag = 888
    private let addCommentLabelTag = 555
    var showAddCommentCell = false {
        didSet {
            print("showAddCommentCell set")
            if showAddCommentCell == oldValue { return }
            
            if showAddCommentCell {
                self.insertRows(at: [IndexPath(row: self.topComments.count, section: 0)], with: .top)
            } else {
                self.deleteRows(at: [IndexPath(row: self.topComments.count, section: 0)], with: .top)
            }
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero, style: .plain)
        self.isScrollEnabled = false
        self.backgroundColor = .black
        self.dataSource = self
        self.delegate = self
        self.register(AddCommentTableViewCell.self, forCellReuseIdentifier: self.addCommentCellID)
        self.separatorStyle = .none
        self.estimatedRowHeight = 20
    }
    
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height + 30)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showAddCommentCell ? self.topComments.count + 1 : self.topComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row != (self.topComments.count + 1) else {
            return self.dequeueReusableCell(withIdentifier: self.addCommentCellID, for: indexPath)
        }
        
        let cell = self.dequeueReusableCell(withIdentifier: self.topCommentCellID, for: indexPath)
        return cell
        
    }
}
