//
//  ChatController.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/07/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  // MARK: - Properties
  
  var user: User?
  var messages = [Message]()
  
  lazy var containerView: UIView = {
    let containerView = UIView()
    
    containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
    
    let sendButton = UIButton(type: .system)
    sendButton.setTitle("Send", for: .normal)
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpOutside)
    
    containerView.addSubview(messageTextField)
    messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 40, width: 0, height: 0)
    
    containerView.addSubview(sendButton)
    sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    
    let separatorView = UIView()
    separatorView.backgroundColor = .lightGray
    containerView.addSubview(separatorView)
    separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.6)
    
    return containerView
  }()
  
  let messageTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Enter Message..."
    return tf
  }()
  
  // MARK: - Init
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.backgroundColor = .white
    
    collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // configure Nav
    configureNavigationBar()
  
  }

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  override var inputAccessoryView: UIView? {
    get {
      return containerView
    }
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }

  
  // MARK: - UICollectionVeiw
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width/2, height: 50)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
    
    cell.backgroundColor = .red
    
    return cell
  }
  
  // MARK: - Handler
  
  @objc func handleSend() {
    print("handleSend")
  }
  
  @objc func handeInfoTapped() {
    print("handeInfoTapped")
  }
  
  func configureNavigationBar() {
    
    guard let user = self.user else { return }
    
    navigationItem.title = user.username
    
    let infoButton = UIButton(type: .infoLight)
    infoButton.tintColor = .black
    infoButton.addTarget(self, action: #selector(handeInfoTapped), for: .touchUpOutside)
    
    let infoBarbuttonItem = UIBarButtonItem(customView: infoButton)
    
    navigationItem.rightBarButtonItem = infoBarbuttonItem
  }
  
  
  
}
