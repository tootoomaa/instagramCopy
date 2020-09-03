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
  var messagesDictionary = [String: Message]()
  
  //MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavigationBar()
    
    fetchMessages()
    
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
    
    cell.message = messages[indexPath.row]
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    let chatpartnerId = message.getChatPartnerId()
    Database.fetchUser(with: chatpartnerId) { (user) in
      self.showChatController(forUser: user)
    }
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
  
  // MARK: - API
  
  func fetchMessages() {
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    self.messages.removeAll()
    self.messagesDictionary.removeAll()
    self.tableView.reloadData()
    
    USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
      
      let uid = snapshot.key
      
      USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded, with: { (snapshot) in
         //각각의 메시지 key를 통해 실제 메시지에 대한 내용을 불러옴
        let messageId = snapshot.key
        self.fetchMessage(withMessageId: messageId)
      })
    }
  }
  
  func fetchMessage(withMessageId messageId: String) {
    MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snaphost) in
      guard let dictionary = snaphost.value as? Dictionary<String, AnyObject> else { return }
      
      let message = Message(dictionary: dictionary)
      
      let chatPartnerId = message.getChatPartnerId()
      // 대화창에 보여줄 정보만 저장 (마지막 대화 정보)
      self.messagesDictionary[chatPartnerId] = message
      // 모든 사용자와의 메시지 정보
      self.messages = Array(self.messagesDictionary.values)
      
      self.tableView?.reloadData()
    }
  }
  
  
  
  
  
  
  
  
  
  
}
