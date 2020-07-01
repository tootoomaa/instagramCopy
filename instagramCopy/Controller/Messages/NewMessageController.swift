//
//  NewMessageController.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/21.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import UIKit
import Firebase

private let reuseIdentifer = "NewMessageCell"

class NewMessageController: UITableViewController {
  //MARK: - Properties
  var users = [User]()
  var messagesController: MessagesController?
  
  
  //MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // configure Navi
    configureNavigationBar()
    
    // set tableView Register
    tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifer)
    
    // fetch User
    fetchUsers()
  }
  
  //MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 75
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! 
    NewMessageCell
    
    cell.user = users[indexPath.row]
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.dismiss(animated: true) {
      let user = self.users[indexPath.row]
      self.messagesController?.showChatController(forUser: user)
    }
  }
  
  //MARK: - Handler
  
  @objc func handleCancle() {
    print("candle")
  }
  
  func configureNavigationBar() {
    navigationItem.title = "Messages"
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancle))

    navigationItem.leftBarButtonItem?.tintColor = .black
    
  }
  
  //MARK: - API
  
  func fetchUsers() {
    USER_REF.observe(.childAdded) { (snapshot) in
      
      let uid = snapshot.key
      
      if uid != Auth.auth().currentUser?.uid {
        Database.fetchUser(with: uid, completion: { (user) in
          self.users.append(user)
          self.tableView.reloadData()
        })
      }
    }
  }
  
}
