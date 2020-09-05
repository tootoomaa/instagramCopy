//
//  CommentInputTextView.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/09/03.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
  
  // MARK: - Properties
  let placeholderLabel: UILabel = {
    let label = UILabel()
    label.text = "Enter Comment..."
    label.textColor = .lightGray
    return label
  }()
  
  // MARK: - Init
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil)
    
    addSubview(placeholderLabel)
    placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Handler
  @objc func handleInputTextChange() {
    placeholderLabel.isHidden = !self.text.isEmpty
  }
}
