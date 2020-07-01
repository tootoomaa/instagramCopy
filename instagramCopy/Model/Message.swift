//
//  Message.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/07/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

class Message {
  
  var messageText: String!
  var formId: String!
  var toId: String!
  var creationDate: Date!
  
  init(dictionary: Dictionary<String, AnyObject>) {
    
    if let messageText = dictionary["MessageText"] as? String {
      self.messageText = messageText
    }
    
    if let formId = dictionary["formId"] as? String {
      self.formId = formId
    }
    
    if let toId = dictionary["toId"] as? String {
      self.toId = toId
    }
    
    if let creationDate = dictionary["creationDate"] as? Double {
      self.creationDate = Date(timeIntervalSince1970: creationDate)
    }
    
  }
  
}
