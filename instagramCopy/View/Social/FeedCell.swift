//
//  FeedCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/10.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class FeedCell: UICollectionViewCell {
  
  var delegate:FeedCellDelegate?
  
  var post: Post? {
    didSet {
      guard let imageUrl = post?.imageUrl else { print("Error2"); return }
      guard let ownerUid = post?.ownerUid else { print("Error1"); return }
      guard let likes = post?.likes else { return }
      
      Database.fetchUser(with: ownerUid) { (user) in
        self.profileImageView.loadImage(with: user.profileImageUrl)
        self.usernameButton.setTitle(user.username, for: .normal)
        self.configurePostCaption(user: user)
      }
      postImageView.loadImage(with: imageUrl)
      likesLabel.text = "\(likes) likes"
      
      configureLikeButton()
    }
  }
  
  let profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  
  lazy var postImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    
    let liketapp = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike))
    liketapp.numberOfTouchesRequired = 2
    
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(liketapp)

    return iv
  }()
  
  lazy var usernameButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setTitle("Username", for: .normal)
    bt.setTitleColor(.black, for: .normal)
    bt.titleLabel?.font = .boldSystemFont(ofSize: 12)
    bt.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
    return bt
  }()
  
  lazy var optionsButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setTitle("•••", for: .normal)
    bt.setTitleColor(.black, for: .normal)
    bt.titleLabel?.font = .boldSystemFont(ofSize: 14)
    bt.addTarget(self, action: #selector(handlOptionsTapped), for: .touchUpInside)
    return bt
  }()
  
  lazy var likesButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
    bt.setImage(#imageLiteral(resourceName: "like_selected"), for: .selected)
    bt.tintColor = .black
    bt.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
    return bt
  }()
  
  lazy var commentButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
    bt.tintColor = .black
    bt.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
    return bt
  }()
  
  let messageButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
    bt.tintColor = .black
    bt.isSelected = false
    return bt
  }()
  
  let savePostButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
    bt.tintColor = .black
    return bt
  }()
  
  lazy var likesLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 12)
    label.text = "3 likes"
    
    // add gesture recongnizer to label
    let liketap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
    liketap.numberOfTouchesRequired = 1
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(liketap)
    return label
  }()
  
  let captionLabel: ActiveLabel = {
    let label = ActiveLabel()
    label.numberOfLines = 0
    return label
  }()
  
  let postTimaLabel: UILabel = {
    let label = UILabel()
    
    label.textColor = .lightGray
    label.font = UIFont.boldSystemFont(ofSize: 10)
    label.text = "2 DAYS AGO"
    
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(profileImageView)
    profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    profileImageView.layer.cornerRadius = 40 / 2
    
    addSubview(usernameButton)
    usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    
    addSubview(optionsButton)
    optionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    
    addSubview(postImageView)
    postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    
    congifureActionButton()
    
    addSubview(likesLabel)
    likesLabel.anchor(top: likesButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    addSubview(captionLabel)
    captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    addSubview(postTimaLabel)
    postTimaLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }
  
  //MARK: - handlers

  @objc func handleDoubleTapToLike() {
    print("handleDoubleTapToLike")
  }
  
  @objc func handleUsernameTapped() {
    delegate?.handleUsernameTapped(for: self)
  }
  
  @objc func handlOptionsTapped() {
    delegate?.handleOptionTapped(for: self)
  }
  
  @objc func handleLikeTapped() {
    delegate?.handleLikeTapped(for: self, isDoubleTap: false)
  }
  
  @objc func handleCommentTapped() {
    delegate?.handleCommentTapped(for: self)
  }
  
  @objc func handleShowLikes() {
    delegate?.handleShowLikes(for: self)
  }
  
  func configureLikeButton() {
    delegate?.handleConfigureLikeButton(for: self)
  }
  
  func configurePostCaption(user:User) {
    
    guard self.post != nil else { return }
    guard let caption = self.post?.caption else { return }
    guard let username = post?.user?.username else { return }
    
    // look for username as pattern
    let customType = ActiveType.custom(pattern: "^\(username)\\b")
    
    // enable username as custom type
    captionLabel.enabledTypes = [.mention, .hashtag, .url, customType]
    
    // configure username link attributes
    captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
      var atts = attributes
      
      switch type {
      case .custom:
        atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
      default: ()
      }
      return atts
    }
    
    captionLabel.customize { (label) in
      label.text = "\(username), \(caption)"
      label.customColor[customType] = .black
      label.font = UIFont.systemFont(ofSize: 12)
      label.textColor = .black
      captionLabel.numberOfLines = 2
    }
    
    postTimaLabel.text = "2 Day Ago"
    
  }
  
  func congifureActionButton() {
    let stackView = UIStackView(arrangedSubviews: [likesButton, messageButton, commentButton])
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    addSubview(stackView)
    stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
    
    addSubview(savePostButton)
    savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
