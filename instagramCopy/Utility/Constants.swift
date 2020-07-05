
//
//  File.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import Firebase

let DB_REF = Database.database().reference()

let USER_REF = Database.database().reference().child("users")

let USER_FOLLOWING_REF = DB_REF.child("user-following")
let USER_FOLLOWER_REF = DB_REF .child("user-followers") //user-followers

let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")

let USER_FEED_REF = DB_REF.child("user-feeds")

let USER_LIKES_REF = DB_REF.child("user-likes")
let POST_LIKES_REF = DB_REF.child("post-likes")

let MESSAGES_REF = DB_REF.child("messages")
let USER_MESSAGES_REF = DB_REF.child("user-messages")

let COMMENT_REF = DB_REF.child("comments")

let NOTIFICATION_REF = DB_REF.child("notifications")

// notification Value
let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
