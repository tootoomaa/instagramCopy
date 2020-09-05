//
//  NotificationVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifer = "NotificationCell"

class NotificationVC: UITableViewController, NotificationCellDelegate {
  
  //MARK: - Properties
  var timer: Timer?
  var currentKey: String?
  var notifications = [Notification]()
  
  
  //MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // clear separator lines
    tableView.separatorColor = .clear
    
    // Nav title
    navigationItem.title = "Notification"
    
    // tableView register
    tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifer)
    
    // fetch notificaion
    fetchNotifications()
    tableView.reloadData()
    
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notifications.count
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if notifications.count > 4 {
      if indexPath.item == notifications.count - 1 {
        fetchNotifications()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! NotificationCell
    
    cell.notification = notifications[indexPath.row]
    
    cell.delegate = self
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let notification = notifications[indexPath.row]
    
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileVC.user = notification.user
    navigationController?.pushViewController(userProfileVC, animated: true)
  }
  
  //MARK: - Protocol
  
  func handleFollowTapped(for cell: NotificationCell) {
    
    guard let user = cell.notification?.user else { return }
    
    if user.isFollowed {
      //handle unFollow User
      user.unfollow()
      cell.followButton.configure(didFollow: false)
      
    } else {
      // handle follow user
      user.follow()
      cell.followButton.configure(didFollow: true)
    }
  }
  
  func handlePostTapped(for cell: NotificationCell) {
    
    guard let post = cell.notification?.post else { return }
    let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
    feedVC.post = post
    navigationController?.pushViewController(feedVC, animated: true)
    
  }
  
  //MARK: - handler
  func handleReloadTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
  }
  
  
  @objc func handleSortNotifications() {
    
    self.notifications.sort { (notification1, notification2) -> Bool in
      return notification1.creationDate > notification2.creationDate
    }
    
    self.tableView.reloadData()
  }
  
  
  //MARK: - API
  func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot) {
    guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
    guard let uid = dictionary["uid"] as? String else { return }
     guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    Database.fetchUser(with: uid, completion: { (user) in
      
      if let postId = dictionary["postId"] as? String {
        
        Database.fetchPost(with: postId, completion: { (post) in
          
          let notification = Notification(user: user, post: post, dictionary: dictionary)
          self.notifications.append(notification)
          self.handleReloadTable()
        })
      } else {
        let notification = Notification(user: user, dictionary: dictionary)
        self.notifications.append(notification)
        self.handleReloadTable()
      }
    })
    NOTIFICATION_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
  }
  
  func fetchNotifications() {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    if currentKey == nil {
      NOTIFICATION_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
        guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
        
        allObject.forEach({ snaphost in
          let notificationId = snaphost.key
          self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
        })
        self.currentKey = first.key
      }
    } else {
      NOTIFICATION_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
        guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
        
        allObject.forEach({ snaphost in
          let notificationId = snaphost.key
          self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
        })
        self.currentKey = first.key
      }
    }
  }
}
