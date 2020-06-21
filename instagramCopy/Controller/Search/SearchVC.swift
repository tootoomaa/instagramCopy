//
//  SearchVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController {

    //MARK: - Properties
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        configureNavController()
        
        // separator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        //fetch Users
        fetchUser()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        //create instance of user profileVC
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVc to userProfileVC
        userProfileVC.user = user
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        cell.user = users[indexPath.row]

        return cell
    }
    
    
    func configureNavController() {
        navigationItem.title = "Explore"
    }
    
    //MARK: - fetch User Data
    func fetchUser() {
        
        Database.database().reference().child("users").observe(.childAdded) { (snaphot) in
            
            // uid
            let uid = snaphot.key
            
            Database.fetchUser(with: uid, completion: { (user) in
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
}

