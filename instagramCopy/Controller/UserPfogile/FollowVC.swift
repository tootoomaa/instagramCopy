//
//  FollowVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowVC: UITableViewController, FollowCellDelegate {
    
    //MARK: -  Properties
    var viewFollowers: Bool?
    //    var viewFollowing: Bool?
    
    var uid: String?
    var users = [User]()//MARK: - FollowCEll delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // configure new controller
        if let viewFollowers = viewFollowers {
            if viewFollowers {
                navigationItem.title = "Followers"
            } else {
                navigationItem.title = "Following"
            }
        }
        tableView.separatorColor = .white
        
        // fetch user data
        fetchUser()
    }
    
    //MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        
        cell.delegate = self
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.currentUser = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    //MARK: - FollowCellDelegate
    func handleFollowTapped(for cell: FollowCell) {
        
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            // configure followed button
            cell.followButton.setTitle("Followed", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        } else {
            user.follow()
            // configure following button
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.backgroundColor = .white
        }
    }
    
    
    //MARK: - API
    func fetchUser() {
        //UserProfileVC 에서 받아온 Uid
        guard let uid = self.uid else { return }
        var ref: DatabaseReference!
        
        if let viewFollowers = viewFollowers {
            if viewFollowers {
                ref = USER_FOLLOWER_REF
            } else {
                //fetch Following
                ref = USER_FOLLOWING_REF
            }
        }
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            //        ref.child(uid).observe(.childAdded) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.forEach { (snapshot) in
                let userId = snapshot.key
                
                Database.fetchUser(with: userId, completion: { (user) in
                    self.users.append(user)
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
}
