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
    sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    
    containerView.addSubview(sendButton)
    sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    
    
    containerView.addSubview(messageTextField)
    messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor , paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
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
  
  //  let sendButton: UIButton = {
  //    let bt = UIButton(type: .system)
  //    bt.setTitle("Send", for: .normal)
  //    bt.titleLabel?.font = .boldSystemFont(ofSize: 14)
  //    bt.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
  //    return bt
  //  }()
  
  // MARK: - Init
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.backgroundColor = .white
    
    collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // configure Nav
    configureNavigationBar()
    
    observeMesages()
    
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
    
    var height: CGFloat = 80
    let message = messages[indexPath.item]
    
    height = estimateFrameForText(message.messageText).height + 20
    
    return CGSize(width: view.frame.width, height: height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
    
    // cell에 메시지 정보 전달
    cell.message = messages[indexPath.item]
    
    // cell의 정렬 방식 설정
    configureMessage(cell: cell, message: messages[indexPath.item])
    
    return cell
  }
  
  // MARK: - Handler
  
  // "Send" 버튼 액션
  @objc func handleSend() {
    uploadMessageToServer()      // 데이터 저장
    messageTextField.text = nil  // 텍스트 필드 초기화
  }
  
  @objc func handeInfoTapped() {
    let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileController.user = user
    navigationController?.pushViewController(userProfileController, animated: true)
  }
  
  func estimateFrameForText(_ text: String) -> CGRect {
    let size = CGSize(width: 200, height: 1000)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  func configureMessage(cell: ChatCell, message: Message) {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
    cell.frame.size.height = estimateFrameForText(message.messageText).height + 20
    
    if message.fromId == currentUid {
      // 로그인 사용자가 보낸 메시지인 경우 오른쪽정렬 활성화
      cell.bubbleViewRightAnchor?.isActive = true // 오른쪽
      cell.bubbleViewleftAnchor?.isActive = false // 왼쪽
      cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
      cell.textView.textColor = .white
      cell.profileImageView.isHidden = true // 프로필 사진 숨김
    } else {
      // 체팅 대상이 보낸 메시지인 경우 왼쪽 정렬 활성화
      cell.bubbleViewRightAnchor?.isActive = false // 오른쪽
      cell.bubbleViewleftAnchor?.isActive = true  // 왼쪽
      cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
      cell.textView.textColor = .black
      cell.profileImageView.isHidden = false // 프로필 사진 표시
    }
  }
  
  func configureNavigationBar() {
    
    guard let user = self.user else { return }
    
    navigationItem.title = user.username
    
    let infoButton = UIButton(type: .infoLight)
    infoButton.tintColor = .black
    infoButton.addTarget(self, action: #selector(handeInfoTapped), for: .touchUpInside)
    
    let infoBarbuttonItem = UIBarButtonItem(customView: infoButton)
    
    navigationItem.rightBarButtonItem = infoBarbuttonItem
  }
  
  // MARK: - API
  
  // 메시지 데이터를 실제로 서버에 저장 하는 부분
  func uploadMessageToServer() {
    // 데이터 검증
    guard let messageText = messageTextField.text else { return }
    guard let currnetUid = Auth.auth().currentUser?.uid else { return }
    guard let user = self.user else { return }
    guard let toUserUid = user.uid else { return }
    
    // message key 생성
    let messageRef = MESSAGES_REF.childByAutoId()
    if let messageKey = messageRef.key {
      
      let creationDate = Int(NSDate().timeIntervalSince1970)
      // 저장 데이터 생성
      let messageValues = ["creationDate": creationDate,
                           "fromId": currnetUid,
                           "toId": toUserUid,
                           "messageText": messageText] as [String: Any]
      // 메시지 데이터 저장
      messageRef.updateChildValues(messageValues)
      
      // 사용자별 메시지 인덱스를 위한 추가정보 저장
      USER_MESSAGES_REF.child(currnetUid).child(toUserUid).updateChildValues([messageKey:1])
      USER_MESSAGES_REF.child(toUserUid).child(currnetUid).updateChildValues([messageKey:1])
    }
  }
  
  func observeMesages() {
    guard let currnetUid = Auth.auth().currentUser?.uid else { return }
    guard let chatPartnerId = user?.uid else { return }
    
    USER_MESSAGES_REF.child(currnetUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
      
      let messageId = snapshot.key
      
      self.fetchMessage(withMessageId: messageId)
    }
    
  }
  
  func fetchMessage(withMessageId messageId: String) {
    MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snaphost) in
      guard let dictionary = snaphost.value as? Dictionary<String, AnyObject> else { return }
      let message = Message(dictionary: dictionary)
      self.messages.append(message )
      self.collectionView.reloadData()
    }
  }
  
  
}
