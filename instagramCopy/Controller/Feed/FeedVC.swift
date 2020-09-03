//
//  FeedVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
  
  //MARK: - Properties
  
  var posts = [Post]()
  var viewSinglePost = false    // UserProfileVC
  var post: Post?               // UserProfileVC
  var currentKey: String?
  var userProfileController: UserProfileVC?
  
  //MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.backgroundColor = .white
    
    //register cell class
    self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
    // configure refrech controll
    let refrechControl = UIRefreshControl()
    refrechControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    collectionView.refreshControl = refrechControl
    
    // configure logour Button
    configureNavigationBar()
    
    // fetch
    if !viewSinglePost { // single post 데이터는 profileViewVc에서 받아옴
      fetchPosts()
    }
    
    updateUserFeeds()
  }
  
  
  //MARK: - UICollectionViewDelegateFlowLayout
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = view.frame.width
    var height = width + 8 + 40 + 8
    height += 50
    height += 60
    
    return CGSize(width: width, height: height)
  }
  
  // MARK: UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if posts.count > 4 {
      if indexPath.item == posts.count - 1{
        fetchPosts()
      }
    }
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if viewSinglePost {
      return 1
    } else {
      return posts.count
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
    
    cell.delegate = self
    
    if viewSinglePost {
      if let post = self.post {
        cell.post = post
      }
    } else {
      cell.post = posts[indexPath.row]
    }
    
    handleHashtagTapped(forCell: cell)
    handleUsernameLabelTapped(forCell: cell)
    handleMentionTapped(forCell: cell)
    
    return cell
  }
  
  //MARK: - FeedCell delegate
  
  func handleUsernameTapped(for cell: FeedCell) {
    print("handleUsernameTapped")
    
    guard let post = cell.post else { return }
    
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    userProfileVC.user = post.user
    
    navigationController?.pushViewController(userProfileVC, animated: true)
  }
  
  func handleOptionTapped(for cell: FeedCell) {
    guard let post = cell.post else { return }
    
    // 포스트를 작성한 사람만 삭제하도록 적용
    if post.ownerUid == Auth.auth().currentUser?.uid {
      let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
      
      alertController.addAction(UIAlertAction(title: "Delete Posrt", style: .destructive, handler: { (_) in
        //delete post here
        post.deletePost()
        
        if !self.viewSinglePost {
          self.handleRefresh()
        } else {
          if let userProfileController = self.userProfileController {
            _ = self.navigationController?.popViewController(animated: true)
            userProfileController.handleRefresh()
          }
        }
      }))
      alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (_) in
        // edit post here
      }))
      
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        // cancel action Sheet
        
      }))
      
      present(alertController, animated: true, completion: nil)
    }
  }
  
  func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
    guard let post = cell.post else { return }
    // handle unlike post
    if post.didLike {
      if !isDoubleTap {
        post.adjustLike(addLike: false, completion:  { (likes) in
          cell.likesButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
          cell.likesLabel.text = "\(likes) likes"
        })
      }
      
    } else {
      // handle like post
      post.adjustLike(addLike: true, completion:  { (likes) in
        cell.likesButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
        cell.likesLabel.text = "\(likes) likes"
      })
    }
  }
  
  func handleConfigureLikeButton(for cell: FeedCell) {
    
    guard let post = cell.post else { return }
    guard let postId = post.postId else { return }
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snaphost) in
      if snaphost.hasChild(postId){
        post.didLike = true
        cell.likesButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
      }
    }
  }
  
  func handleShowLikes(for cell: FeedCell) {
    print("tab likes Label")
    
    guard let post = cell.post else { return }
    guard let postId = post.postId else { return }
    
    let followLikeVC = FollowLikeVC()
    followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
    followLikeVC.postId = postId
    navigationController?.pushViewController(followLikeVC, animated: true)
  }
  
  func handleCommentTapped(for cell: FeedCell, isDoubleTab: Bool) {
    
  }
  
  
  // MARK: Handlers
  func handleDoubleTapToLike(for cell: FeedCell) {
    print("handleDoubleTapToLike")
  }
  
  @objc func handleRefresh() {
    posts.removeAll(keepingCapacity: false)
    self.currentKey = nil
    fetchPosts()
    collectionView?.reloadData()
  }
  
  @objc func handleShowMessages() {
    let messagesContoller = MessagesController()
    navigationController?.pushViewController(messagesContoller, animated: true)
  }
  
  
  func handleHashtagTapped(forCell cell: FeedCell) {
    cell.captionLabel.handleHashtagTap { (hashtag) in
      let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
      hashtagController.hashtag = hashtag
      self.navigationController?.pushViewController(hashtagController, animated: true)
    }
  }
  
  func handleMentionTapped(forCell cell: FeedCell) {
    cell.captionLabel.handleMentionTap { (username) in
      self.getMentionedUser(withUsername: username)
    }
  }
  
  func handleUsernameLabelTapped(forCell cell: FeedCell) {
    guard let user = cell.post?.user else { return }
    guard let username = user.username else { return }
    
    let customType = ActiveType.custom(pattern: "^\(username)\\b")
    
    cell.captionLabel.handleCustomTap(for: customType) { (_) in
      let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
      self.navigationController?.pushViewController(userProfileController, animated: true)
    }
  }
  
  func handleCommentTapped(for cell: FeedCell) {
    guard let post = cell.post else { return }
    let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
    commentVC.post = post
    navigationController?.pushViewController(commentVC, animated: true)
  }
  
  func configureNavigationBar() {
    
    if !viewSinglePost {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
      
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
      
      self.navigationItem.title = "Feed"
    }
  }
  
  @objc func handleLogout() {
    //declare slert controller
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    //add alert action
    alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive  ,handler: { (_) in
      do {
        // attemp sign out
        try Auth.auth().signOut()
        
        //present login controller
        let loginVC = LoginVC()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
        print("SucessFull Log out User")
      } catch {
        //handle erorr
        print("Failed to sign out")
      }
    }))
    // configure Alert Button
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
  
  //MARK: - API
  
  func updateUserFeeds() {
    // let USER_POSTS_REF = DB_REF.child("user-posts")
    // let USER_FEED_REF = DB_REF.child("user-feeds")
    
    guard let currentUid = Auth.auth().currentUser?.uid else {return}
    
    USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
      
      let followingUserId = snapshot.key
      USER_POSTS_REF.child(followingUserId).observe(.childAdded, with: { (snapshot) in
        
        let postId = snapshot.key
        
        USER_FEED_REF.child(currentUid).updateChildValues([postId:1])
      })
    }
    
    
    USER_POSTS_REF.child(currentUid).observe(.childAdded, with: { (snapshot) in
      
      let postId = snapshot.key
      
      USER_FEED_REF.child(postId).updateChildValues([postId:1])
      
    })
  }
  
  func fetchPosts() {
    
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    if self.currentKey == nil {
      // 최초의 데이터 불러옴
      print("Fisrt Post Fetch Start")
      USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
        print("First Fetch: ",snapshot)
        self.collectionView?.refreshControl?.endRefreshing()
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
        guard let allObject =  snapshot.children.allObjects as? [DataSnapshot] else { return }
        
        print("First : ",first)
        allObject.forEach({ (snapshot) in
          let postId = snapshot.key
          self.fetchPost(withPostId: postId)
        })
        
        self.currentKey = first.key
      }
    } else {
      // 두번째 데이터를 불러올 때부터 사용되는 구문
      USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with:  { (snapshot) in
        
        guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
        guard let allObject =  snapshot.children.allObjects as? [DataSnapshot] else { return }
        
        allObject.forEach({ (snapshot) in
          let postId = snapshot.key
          if postId != self.currentKey {
            self.fetchPost(withPostId: postId)
          }
        })
        self.currentKey = first.key
      })
    }
  }
  
  
  func fetchPost(withPostId postId: String) {
    print("Fetch Poat by Postid : ",postId)
    Database.fetchPost(with: postId) { (post) in
      self.posts.append(post)
      
      self.posts.sort(by:{ (post1, post2) -> Bool in
        return post1.creationDate > post2.creationDate
      })
      self.collectionView?.reloadData()
      
    }
  }
}

