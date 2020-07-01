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
  var messages = [Message]()
  
  //MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavigationBar()
    
    tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifer)
  }
  
  //MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 75
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
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
    let newMessageController = NewMessageController()
    newMessageController.messagesController = self
    let navigationController = UINavigationController(rootViewController: newMessageController)
    navigationController.modalPresentationStyle = .fullScreen
    self.present(navigationController, animated: true, completion: nil)
  }
  
  func showChatController(forUser user: User) {
    let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
    chatController.user = user
    navigationController?.pushViewController(chatController, animated: true)
  }
  
  func configureNavigationBar() {
    navigationItem.title = "Messages"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
}
