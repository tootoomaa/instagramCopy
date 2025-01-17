//
//  NotificationCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/13.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
  
  //MARK: - Properties
  
  var delegate: NotificationCellDelegate?
  var notification: Notification? {
    
    didSet {
      
      guard let user = notification?.user else { return }
      guard user.profileImageUrl != nil else { return }
      
      // configure notification Message
      configureNotificationLabel()
      
      // configure notification Type
      configureNotificationType()
      
      profileImageView.loadImage(with: user.profileImageUrl)
      
      if let post = notification?.post {
        postImageView.loadImage(with: post.imageUrl)
      }
    }
    
  }
  
  let profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  
  let notificationLabel: UILabel = {
    let label = UILabel()
    
    let attributedText = NSMutableAttributedString(string: "Jocker", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
    attributedText.append(NSAttributedString(string: " comment on Posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    attributedText.append(NSAttributedString(string: " 2d.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    label.attributedText = attributedText
    label.numberOfLines = 2
    return label
  }()
  
  let followButton: UIButton = {
    let bt = UIButton(type: .system)
    bt.setTitle("Loading", for: .normal)
    bt.setTitleColor(.white, for: .normal)
    bt.layer.borderColor = CGColor(srgbRed: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    bt.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    bt.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
    return bt
  }()
  
  lazy var postImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    
    let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
    postTap.numberOfTapsRequired = 1
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(postTap)
    
    return iv
  }()
  
  //MARK: - handlers
  
  @objc func handleFollowTapped() {
    delegate?.handleFollowTapped(for: self)
  }
  
  @objc func handlePostTapped() {
    delegate?.handlePostTapped(for: self)
  }
  
  func configureNotificationLabel() {
    guard let notification = self.notification else { return }
    guard let user = notification.user else { return }
    guard let username = user.username else { return }
    guard let notificationDate = getNotificationTimeStamp() else { return }
    let notificationMessage = notification.notificationType.description
    
    let attributedText = NSMutableAttributedString(string: "\(username)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
    attributedText.append(NSAttributedString(string: " \(notificationMessage)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]))
    attributedText.append(NSAttributedString(string: " \(notificationDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
    
    notificationLabel.attributedText = attributedText
  }
  
  func configureNotificationType() {
    guard let notification = self.notification else { return }
    guard notification.user != nil else { return }
    guard let user = notification.user else { return }
    
    if notification.notificationType != .Follow {
      
      // notification type is comment or like
      addSubview(postImageView)
      postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
      postImageView.centerYAnchor.constraint(equalTo : self.centerYAnchor).isActive = true
      followButton.isHidden = true
    } else {
      // notification type is Follow
      addSubview(followButton)
      followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
      followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
      followButton.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
      
      user.checkIfUserIsFollowed(completion: { (followed) in
        
        if followed {
          
          // configure follow button
          self.followButton.setTitle("Following", for: .normal)
          self.followButton.setTitleColor(.black, for: .normal)
          self.followButton.layer.borderColor = UIColor.lightGray.cgColor
          self.followButton.layer.borderWidth = 0.5
          self.followButton.backgroundColor = .white
          
        } else {
          
          // configure Followed buttonm
          self.followButton.setTitle("Follow", for: .normal)
          self.followButton.setTitleColor(.white, for: .normal)
          self.followButton.layer.borderWidth = 0
          self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
      })
    }
    
    addSubview(notificationLabel)
    notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 100, width: 0, height: 0)
    notificationLabel.centerYAnchor.constraint(equalTo : self.centerYAnchor).isActive = true
  }
  
  func getNotificationTimeStamp() -> String? {
    
    guard let notification = self.notification else { return nil }
    
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
    dateFormatter.maximumUnitCount = 1
    dateFormatter.unitsStyle = .abbreviated
    
    let now = Date()
    return dateFormatter.string(from: notification.creationDate, to: now)
    
  }
  
  
  
  //MARK: - init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    
    selectionStyle = .none
    
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    profileImageView.centerYAnchor.constraint(equalTo : self.centerYAnchor).isActive = true
    profileImageView.layer.cornerRadius = 40 / 2
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
