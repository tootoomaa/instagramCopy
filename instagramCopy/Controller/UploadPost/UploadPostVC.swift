//
//  UploadPostVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController,UITextViewDelegate {
  
  //MARK: - Properties
  enum UploadAction: Int{
    case UploadPost
    case SaveChange
    
    init(index: Int) {
      switch index {
      case 0: self = .UploadPost
      case 1: self = .SaveChange
      default: self = .UploadPost
      }
    }
  }
  
  var uploadAction: UploadAction = .UploadPost
  var selectedImage: UIImage?
  var postToEdit: Post?
  
  var photoImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  let captionTextView: UITextView = {
    let tv = UITextView()
    tv.backgroundColor = UIColor.groupTableViewBackground
    tv.font = UIFont.systemFont(ofSize: 12)
    return tv
  }()
  
  let actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
    button.setTitle("Share", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 5
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    // load image
    loadImage()
    
    // TextView Delegate
    captionTextView.delegate = self
    
    // configure View component
    configureViewCompnent()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
   
    if uploadAction == .SaveChange {
      guard let post = self.postToEdit else { return }
      photoImageView.loadImage(with: post.imageUrl)
      captionTextView.text = post.caption
      self.navigationItem.title = "Edit Post"
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
      self.navigationController?.navigationBar.tintColor = .black
      actionButton.setTitle("Save change", for: .normal)
    } else {
      actionButton.setTitle("Share", for: .normal)
      self.navigationItem.title = "Upload Post"
    }
  }
  
  //MARK: - UITextViewDelegate
  func textViewDidChange(_ textView: UITextView) {
    guard !textView.text.isEmpty else {
      actionButton.isEnabled = false
      actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
      return
    }
    
    actionButton.isEnabled = true
    actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
  }
  
  // MARK: - Handler
  @objc func handleCancel() {
    self.dismiss(animated: true, completion: nil)
  }
  
  //MARK: - Post handler
  
  func updateUserFetchFeeds(with postId:String) {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
    //datavase value
    let values = [postId: 1]
    
    // 현재 사용자를 팔로우하고 있는 사용자들의 user-feeds에 데이터 추가
    USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
      
      let followerUid = snapshot.key
      USER_FEED_REF.child(followerUid).updateChildValues(values)
    }
    
    // 현재 사용자의 user-feeds에 추가 등록
    USER_FEED_REF.child(currentUid).updateChildValues(values)
    
  }
  
  @objc func handleUploadAction() {
    buttonSelector(uploadAction: uploadAction)
  }
  
  func buttonSelector(uploadAction: UploadAction) {
    switch uploadAction {
    case .UploadPost:
      handleUploadPost()
    case .SaveChange:
      handleSavePostChanges()
    }
  }
  
  func handleSavePostChanges() {
    guard let post = self.postToEdit else { return }
    guard let updatedCaption = captionTextView.text else { return }
    
    uploadHashTagToServer(withPostId: post.postId)
    
    POSTS_REF.child(post.postId).child("caption").setValue(updatedCaption) { (err, erf) in
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func handleUploadPost() {
    guard
      let caption = captionTextView.text,
      let postImg = photoImageView.image,
      let currentUid = Auth.auth().currentUser?.uid else { return }
    
    guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
    
    // creation data
    let creationDate = Int(NSDate().timeIntervalSince1970)
    
    // update stroage
    let filename = NSUUID().uuidString
    Storage.storage().reference().child("post_images").child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
      
      // handle Error
      if let error = error {
        print("Fialed to upload image to storage with Error", error.localizedDescription)
        return
      }
      
      // get posts image URL
      Storage.storage().reference().child("post_images").child(filename).downloadURL { (url, error) in
        if error != nil {
          print("make imageUrl Error")
          return
        } else {
          // check URL
          guard let url = url else { return }
          
          let values =
            ["caption" : caption,
             "creationDate" : creationDate,
             "likes" : 0,
             "imageUrl" : url.absoluteString,
             "ownerUid" : currentUid] as [String:Any]
          
          // post id
          let postId = POSTS_REF.childByAutoId()
          
          // upload information to database
          postId.updateChildValues(values) { (erro, ref) in
            
            // update user-post structure
            guard let postidKey = postId.key else {return}
            DB_REF.child("user-posts").child(currentUid).updateChildValues([postidKey:1])
            
            // update user-feed structure
            self.updateUserFetchFeeds(with: postidKey)
            
            // update Hashtag to Server
            self.uploadHashTagToServer(withPostId: postidKey)
            
            // upload mention notification to server
            if caption.contains("@") {
              guard let postId = postId.key else { return }
              self.uploadMentionNofiticationToServer(forPostID: postId, withText: caption, isForComment: false)
            }
            
            // return to home feed
            self.dismiss(animated: true,completion: {
              self.tabBarController?.selectedIndex = 0
            })
          }
        }
      }
    }
  }
  
  func configureViewCompnent() {
    view.addSubview(photoImageView)
    photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
    view.addSubview(captionTextView)
    captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 100)
    view.addSubview(actionButton)
    actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
  }
  
  func loadImage() {
    guard let selectedImage = self.selectedImage else {return}
    photoImageView.image = selectedImage
  }

  // MARK: - API
  
  
  func uploadHashTagToServer(withPostId postId: String) {
    
    guard let caption = captionTextView.text else { return }
    
    let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
    
    for var word in words {
      
      if word.hasPrefix("#") {
        word = word.trimmingCharacters(in: .punctuationCharacters)
        word = word.trimmingCharacters(in: .symbols)
        
        let hashtagValues = [postId: 1]
        
        HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
      }
    }
  }
}
