//
//  Post.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/09.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase

class Post {
  
  var caption: String!
  var likes: Int!
  var imageUrl: String!
  var ownerUid: String!
  var creationDate: Date!
  var postId: String!
  var user: User?
  var didLike = false
  
  init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
    
    self.postId = postId
    
    self.user = user
    
    if let caption = dictionary["caption"] as? String {
      self.caption = caption
    }
      
    if let likes = dictionary["likes"] as? Int {
      self.likes = likes
    }
    
    if let imageUrl = dictionary["imageUrl"] as? String {
      self.imageUrl = imageUrl
    }
    
    if let ownerUid = dictionary["ownerUid"] as? String {
      self.ownerUid = ownerUid
    }
    
    if let creationDate = dictionary["creationDate"] as? Double {
      self.creationDate = Date(timeIntervalSince1970: creationDate)
    }
  }
  
  // 포스팅 정보를 자동으로 셋팅
  func adjustLike(addLike: Bool, completion: @escaping(Int) -> ()) {
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    guard let postId = postId else { return }
    if addLike {
      
      //update user-likes structure
      USER_LIKES_REF.child(currentUid).updateChildValues([postId:1], withCompletionBlock: { (err, ref) in
        
        // sendLike Notification To Server
        self.sendLikeNotificationToServer()
        
        // update posr-likes structure
        POST_LIKES_REF.child(self.postId).updateChildValues([currentUid:1]) { (err, ref) in
          self.likes = self.likes + 1
          self.didLike = true
          completion(self.likes)
          // 좋아요를 누른 포스트의 BD내 likes 숫자 업데이트
          POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
        }
      })
    } else {
      // observe database for notification id to remove
      USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value, with: { (snaphost) in
        print(snaphost)
        // notification id to remove from server
        guard let notificationID = snaphost.value as? String else { return }
        
        // remove notification from server
        NOTIFICATION_REF.child(self.ownerUid).child(notificationID).removeValue(completionBlock: { (err, ref) in
          // remove like from user-likes structure
          
          USER_LIKES_REF.child(currentUid).child(self.postId).removeValue( completionBlock: { (err, ref) in
          
            // remove like from post-likes structure
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue(completionBlock: { (err, ref) in
              guard self.likes > 0 else {return}
              self.likes = self.likes - 1
              self.didLike = false
              completion(self.likes)
              // 좋아요를 누른 포스트의 BD내 likes 숫자 업데이트
              POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
            })
          })
        })
      })
    }
  }
  
  func deletePost() {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    // 기존 저장된 포스팅의 사진 삭제
    Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
    
    USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
      let followerUid = snapshot.key
      USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
    }
    
    USER_FEED_REF.child(currentUid).child(postId).removeValue()
    USER_POSTS_REF.child(currentUid).child(postId).removeValue()
    
    USER_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
      let uid = snapshot.key
      USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value) { (snapshot) in
        guard let notificationId = snapshot.value as? String else { return }
        NOTIFICATION_REF.child(self.ownerUid).child(notificationId).removeValue { (err, ref) in
          POST_LIKES_REF.child(self.postId).removeValue()
          USER_LIKES_REF.child(uid).child(self.postId).removeValue()
        }
      }
    }
    
    let words = caption.components(separatedBy: .whitespacesAndNewlines)
    
    for var word in words {
      if word.hasPrefix("#") {
        word = word.trimmingCharacters(in: .punctuationCharacters)
        word = word.trimmingCharacters(in: .symbols)
        
        HASHTAG_POST_REF.child(word).child(postId).removeValue()
      }
    }
    
    COMMENT_REF.child(postId).removeValue()
    POSTS_REF.child(postId).removeValue()
  }
  
  func sendLikeNotificationToServer() {
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    // only send notification if like is for post that is not currnt users
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    if currentUid != self.ownerUid {  // 자기 자신한테는 보내지 않음
      
      guard let postId = self.postId else { return }
      let values = ["checked": 0,
                    "creationDate": creationDate,
                    "uid": currentUid,
                    "type": LIKE_INT_VALUE,
                    "postId": postId] as [String : Any]
      
      
      // notification Database reference
      // make notification ID
      let nofiticationRef = NOTIFICATION_REF.child(self.ownerUid).childByAutoId()
      
      // upload notification Value to database
      nofiticationRef.updateChildValues(values, withCompletionBlock: { (err,ref) in
        USER_LIKES_REF.child(currentUid).child(postId).setValue(nofiticationRef.key)
      })
    }
  }
  
}
