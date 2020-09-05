//
//  HashtagController.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/07/06.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseableIdentifier = "HashtagCell"

class HashtagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  // MARK: - Properties
  var posts = [Post]()
  var hashtag:String?
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.backgroundColor = .white
    collectionView.register(HashtagCell.self, forCellWithReuseIdentifier: reuseableIdentifier)
    
    configureNavigationBar()
    
    fetchPosts()
    
  }
  
  // MARK: - UICollectionViewFlowLayout
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
     return 1
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
     return 1
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     let width = (view.frame.width-2) / 3
     return CGSize(width: width, height: width)
   }
  
    // MARK: - UICollectionView DataSource
   
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return posts.count
   }
   
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseableIdentifier, for: indexPath) as! HashtagCell
     
     cell.post = posts[indexPath.item]
     
     return cell
   }
   
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
     feedVC.viewSinglePost = true
     feedVC.post = posts[indexPath.item]
     
     navigationController?.pushViewController(feedVC, animated: true)
   }
  
  func configureNavigationBar() {
    
    guard let hashtag = self.hashtag else { return }
    navigationItem.title = hashtag
  }
  
  func fetchPosts() {
    
    guard let hashtag = hashtag else { return }
    
    HASHTAG_POST_REF.child(hashtag.lowercased()).observe(.childAdded) { (snapshot) in
      
      let postId = snapshot.key
      
      Database.fetchPost(with: postId) { (post) in
        self.posts.append(post)
        self.collectionView.reloadData()
      }
    }
  }
}
