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
    var selectedImage: UIImage?
    
    var photoImageView: UIImageView = {
        let iv = UIImageView()
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
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handlerPostButton), for: .touchUpInside)
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
    
    //MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    
    //MARK: - Post handler
    @objc func handlerPostButton() {
        
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
        
        // creation data
        let creationData = Int(NSDate().timeIntervalSince1970)
        
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
                     "creationData" : creationData,
                     "likes" : 0,
                     "imageUrl" : url.absoluteString,
                     "ownerUid" : currentUid] as [String:Any]

                    // post id
                    let postId = POSTS_REF.childByAutoId()
                    
                    // upload information to database
                    postId.updateChildValues(values) { (erro, ref) in
                        self.dismiss(animated: true) {
                            self.tabBarController?.selectedIndex = 0
                        }
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
            view.addSubview(shareButton)
            shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
        }
            
        func loadImage() {
            guard let selectedImage = self.selectedImage else {return}
            photoImageView.image = selectedImage
        }
}
