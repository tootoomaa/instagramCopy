//
//  Comment.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase

class Comment {
  
  var uid:String!
  var commentText: String!
  var creationDate: NSDate!
  var user: User?
  
  
  init(user: User, dictionary: Dictionary<String,AnyObject>) {
    
    self.user = user
    
    if let uid = dictionary["uid"] as? String {
      self.uid = uid
    }
    
    if let commentText = dictionary["commentText"] as? String {
      self.commentText = commentText
    }

    if let creationDate = dictionary["creationDate"] as? Double {
      self.creationDate = Date(timeIntervalSince1970: creationDate) as NSDate
    }
  }
}
