//
//  User.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/12.
//  Copyright © 2020 김광수. All rights reserved.
//
import Firebase

class User {
    // attribute
    var username:String!
    var name:String!
    var profileImageUrl:String!
    var uid:String!
    var isFollowed:Bool!
    
    init(uid:String, dictionary: Dictionary<String, AnyObject>) {
        self.uid = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow() {
        guard let currnetUid = Auth.auth().currentUser?.uid else { return }
        
        // Update: - get uid like this to work with update
        guard let uid = uid else { return }
        // set is followed to true
        
        self.isFollowed = true
        // add followed to true
        USER_FOLLOWING_REF.child(currnetUid).updateChildValues([uid: 1])
    
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(self.uid).updateChildValues([currnetUid: 1])
    }

    func unfollow() {
        guard let currnetUid = Auth.auth().currentUser?.uid else { return }
        
        // set is followed to false
        self.isFollowed = false
    
        // remove user frome current user-following structure
        USER_FOLLOWING_REF.child(currnetUid).child(self.uid).removeValue()
        
        // remove current user from user-following structure
        USER_FOLLOWER_REF.child(self.uid).child(currnetUid).removeValue()
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool)->()) {
        guard let currnetUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currnetUid).observeSingleEvent(of: .value) { (snapchot) in
            
            if snapchot.hasChild(self.uid) {
                
                self.isFollowed = true
                completion(true)
//                self.follow()
            } else {
                
                self.isFollowed = false
                completion(false)
//                self.unfollow()
            }
        }
    }
}
