//
//  CommandVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/12.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  //MARK: - Properties
  var post: Post?
  var comments = [Comment]()

  lazy var containerView: CommentInputAccessoryView = {
    let frame = CGRect(x: 0 , y: 0, width: view.frame.width, height: 50)
    let containerView = CommentInputAccessoryView(frame: frame)
    containerView.backgroundColor = .white
    containerView.delegate = self
    return containerView
  }()
  
  //MARK: - init
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // configure collection view
    collectionView?.backgroundColor = .white
    collectionView?.alwaysBounceVertical = true
    collectionView?.keyboardDismissMode = .interactive
    
    collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
    collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
    
    // navigation title
    navigationItem.title = "Comments"
    
    // register Cell Class
    collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // fetch comment
    fetchComment()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  override var inputAccessoryView: UIView? {
    get {
      return containerView
    }
  }
  
  //키보트의 커서가 자동을 이동됨
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  
  //MARK: - UICollectionView
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    let dummyCell = CommentCell(frame: frame)
    dummyCell.comment = comments[indexPath.item]
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: view.frame.width, height: 1000)
    let estimateSize = dummyCell.systemLayoutSizeFitting(targetSize)
    
    let height = max(40 + 8 + 8,estimateSize.height)

    return CGSize(width: view.frame.width, height: height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return comments.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
    
    handleHashtagTapped(forCell: cell)
    handleMenstionTapped(forCell: cell)
    
    cell.comment = comments[indexPath.item]
    
    return cell
  }
  
  //MARK: - handlers
  func handleHashtagTapped(forCell cell: CommentCell) {
    cell.commentLabel.handleHashtagTap { (hashtag) in
      let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
      hashtagController.hashtag = hashtag
      self.navigationController?.pushViewController(hashtagController, animated: true)
    }
  }
  
  func handleMenstionTapped(forCell cell: CommentCell) {
    cell.commentLabel.handleMentionTap { (username) in
      print("mentioned Username is \(username)")
      self.getMentionedUser(withUsername: username)
    }
  }
  
  // MARK: - API
  func fetchComment() {
    guard let post = self.post else { return }
    guard let postId = post.postId else { return }
    
    COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
      
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
      guard let uid = dictionary["uid"] as? String else { return }
      
      Database.fetchUser(with: uid, completion: { (user) in
        
        let comment = Comment(user: user, dictionary: dictionary)
        self.comments.append(comment)
        self.collectionView.reloadData()
      })
    }
  }
  
  func uploadCommentNotificationToServer() {
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    guard let postId = self.post?.postId else { return }
    guard let uid = post?.user?.uid else { return  }
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    // notification Values
    let values = ["checked": 0,
                  "creationDate": creationDate,
                  "uid": currentUid,
                  "type": COMMENT_MENTION_INT_VALUE,
                  "postId": postId] as [String : Any]
    
    // update Notification values
    if uid != currentUid {
      NOTIFICATION_REF.child(uid).childByAutoId().updateChildValues(values)
    }
  }
}

extension CommentVC: CommentInputAccessoryViewDelegate {
  
  func didSubmit(forComment comment: String) {
    guard let postId = self.post?.postId else { return }
    guard let uid = Auth.auth().currentUser?.uid else {return}
    
    // 생성 시간 생성
    let creationDate = Int(NSDate().timeIntervalSince1970)
    // FireBaseDB 에 저장할 데이터 생성
    let value = ["commentText": comment,
                 "creationDate": creationDate,
                 "uid": uid] as [String:Any]
    // 자동으로 key를 생성(childByAutoId()) 한뒤 Value값을 저장
    COMMENT_REF.child(postId).childByAutoId().updateChildValues(value) { (err, ref) in
      self.uploadCommentNotificationToServer()
      if comment.contains("@") {
        self.uploadMentionNofiticationToServer(forPostID: postId, withText: comment, isForComment: true)
      }
      self.containerView.clearCommentTextView()
    }
  }
}
