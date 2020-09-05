//
//  CommentInputAccessoryView.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/09/03.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class CommentInputAccessoryView: UIView {

  // MARK: - Properties
  var delegate: CommentInputAccessoryViewDelegate?
  
  let commentTextView: CommentInputTextView = {
    let tv = CommentInputTextView()
    tv.font = .systemFont(ofSize: 16)
    tv.isScrollEnabled = false
//    tv.placeholder = "   Enter comment... "
    return tv
  }()
  
  let postButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setTitle("Post", for: .normal)
    bt.setTitleColor(.black, for: .normal)
    bt.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    bt.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
    return bt
  }()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    autoresizingMask = .flexibleHeight
    
    addSubview(postButton)
    postButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
    
    addSubview(commentTextView)
    commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: postButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    let separatorView = UIView()
    separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    
    addSubview(separatorView)
    separatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Handlers
  
  @objc func handleUploadComment() {
    guard let comment = commentTextView.text else { return }
    delegate?.didSubmit(forComment: comment)
  }
  
  override var intrinsicContentSize: CGSize {
    return .zero
  }
  
  func clearCommentTextView() {
    commentTextView.text = nil
  }
}
