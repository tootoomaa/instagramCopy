//
//  MessagesController.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/21.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase

private let reuseIdentifer = "MessagesCell"
class MessagesController: UITableViewController {
  
  //MARK: - Properties
  
  
  //MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifer)
  }
  
  //MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 75
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! MessageCell
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("selectRow")
  }
  
  //MARK: - Handler
  
  @objc func handleNewMessage() {
    print("handleNewMessage")
    
  }
  
  func configureNavigationBar() {
    navigationItem.title = "Messages"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
