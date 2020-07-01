//
//  FeedVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
  
  //MARK: - Properties
  
  var posts = [Post]()
  var viewSinglePost = false    // UserProfileVC
  var post: Post?               // UserProfileVC
  
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
    print("handleOptionTapped")
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
    fetchPosts()
    collectionView?.reloadData()
  }
  
  @objc func handleShowMessages() {
    let messagesContoller = MessagesController()
    navigationController?.pushViewController(messagesContoller, animated: true)
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
    
    USER_FEED_REF.child(currentUid).observe(.childAdded) { (snaphot) in
      
      let postId = snaphot.key
      
      Database.fetchPost(with: postId, completion:  { (post) in
        self.posts.append(post)
        
        self.posts.sort(by: {(post1, post2) -> Bool in
          return post1.creationDate > post2.creationDate
        })
        
        // stop refreching
        self.collectionView?.refreshControl?.endRefreshing()
        
        self.collectionView?.reloadData()
      })
    }
  }
}

