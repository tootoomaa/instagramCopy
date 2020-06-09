
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

let USER_FOLLOWING_REF = Database.database().reference().child("user-following")
let USER_FOLLOWER_REF = Database.database().reference().child("user-followers") //user-followers

let POSTS_REF = DB_REF.child("posts")

