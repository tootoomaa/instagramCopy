//
//  ChatCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/07/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class ChatCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  var bubbleWidthAnchor: NSLayoutConstraint?
  var bubbleViewRightAnchor: NSLayoutConstraint?
  var bubbleViewleftAnchor: NSLayoutConstraint?
  
  var message: Message? {
    didSet {
      
      guard let messageText = message?.messageText else { return }
      textView.text = messageText
      
      guard let chatPartnerId = message?.getChatPartnerId() else { return }
      
      Database.fetchUser(with: chatPartnerId) { (user) in
        guard let profileImageUrl = user.profileImageUrl else { return }
        self.profileImageView.loadImage(with: profileImageUrl)
        
      }
      
    }
  }
  
  let bubbleView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
    view.layer.cornerRadius = 16
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.masksToBounds = true
    return view
  }()
  
  let textView: UITextView = {
    let tv = UITextView()
    tv.text = "Sample text fro now"
    tv.font = .systemFont(ofSize: 16)
    tv.backgroundColor = .clear
    tv.textColor = .white
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.isEditable = false
    return tv
  }()
  
  let profileImageView: CustomImageView = {
      let iv = CustomImageView()
      iv.contentMode = .scaleAspectFill
      iv.clipsToBounds = true
      iv.backgroundColor = .lightGray
      return iv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(bubbleView)
    addSubview(textView)
    addSubview(profileImageView)
    
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: -4, paddingRight: 0, width: 32, height: 32)
    profileImageView.layer.cornerRadius = 32/2
   
    // bubbleView right Anchor
    bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
    bubbleViewRightAnchor?.isActive = true
    
    // bubbleView left Anchor
    bubbleViewleftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
    bubbleViewleftAnchor?.isActive = true
    
    // bubbleView top Anchor
    bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
    bubbleWidthAnchor?.isActive = true
    bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
    
    // bubble View Text View anchor
    textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
    textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
    textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
    textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
