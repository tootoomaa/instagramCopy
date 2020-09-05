//
//  EditProfileController.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/09/03.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UIViewController {
  
  // MARK: - Properties
  var user: User? {
    didSet {
      guard let user = user else { return }
      usernameTextField.text = user.username
      fullnameTextField.text = user.name
      profileImageView.loadImage(with: user.profileImageUrl)
    }
  }
  
  var imageChanged = false
  var usernameChanged = false
  var userProfileController: UserProfileVC?
  var updateUsername: String?
  
  let profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  
  let changePhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Change Profile Photo", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 14)
    button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
    return button
  }()
  
  let separatorView: UIView = {
    let view = UIView()
    view.backgroundColor = .lightGray
    return view
  }()
  
  lazy var usernameTextField: UITextField = {
    let tf = UITextField()
    tf.textAlignment = .left
    tf.delegate = self
    return tf
  }()
  
  lazy var fullnameTextField: UITextField = {
    let tf = UITextField()
    tf.textAlignment = .left
    tf.delegate = self
    tf.isUserInteractionEnabled = false
    return tf
  }()
  
  let fullnameLabel: UILabel = {
    let label = UILabel()
    label.text = "Full Name"
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.text = "user Name"
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  let fullnameSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = .lightGray
    return view
  }()
  
  let usernameSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = .lightGray
    return view
  }()
  
  // MARK: - Init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    configureNavigationBar()
    
    configureViewComponents()
  }
  
  
  // MARK: - Button Handler
  @objc func handleChangeProfilePhoto() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @objc func handleCancel() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func handleDone() {
    view.endEditing(true)
    if usernameChanged {
      updateUserName()
    }
    
    if imageChanged {
      updateProfileImage()
    }
  }
  
  // MARK: - Handler
  func configureViewComponents() {
    let frame = CGRect(x: 0, y: 88, width: view.frame.size.width, height: 150)
    let containerView = UIView(frame: frame)
    
    containerView.backgroundColor = .systemGray4
    view.addSubview(containerView)
    
    containerView.addSubview(profileImageView)
    profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    profileImageView.layer.cornerRadius = 80/2
    
    containerView.addSubview(changePhotoButton)
    changePhotoButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    
    containerView.addSubview(separatorView)
    separatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    containerView.addSubview(fullnameLabel)
    fullnameLabel.anchor(top: containerView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    containerView.addSubview(usernameLabel)
    usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(fullnameTextField)
    fullnameTextField.anchor(top: containerView.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: view.frame.width/1.6, height: 0)
    
    view.addSubview(usernameTextField)
    usernameTextField.anchor(top: fullnameTextField.bottomAnchor, left: usernameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: view.frame.width/1.6, height: 0)
    
    view.addSubview(fullnameSeparatorView)
    fullnameSeparatorView.anchor(top: nil, left: fullnameTextField.leftAnchor, bottom: fullnameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
    
    view.addSubview(usernameSeparatorView)
    usernameSeparatorView.anchor(top: nil, left: usernameTextField.leftAnchor, bottom: usernameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
  }
  
  func configureNavigationBar() {
    title = "Edit Profile"
    navigationController?.navigationBar.tintColor = .black
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancel))
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(handleDone))
  }
  
  // MARK: - API
  
  func updateProfileImage() {
    guard imageChanged == true else { return }
    guard let currnetUid = Auth.auth().currentUser?.uid else { return }
    guard let user = self.user else { return }
    
    Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
    
    let filename = NSUUID().uuidString
    
    guard let updateProfileImage = profileImageView.image else { return }
    
    guard let imageData = updateProfileImage.jpegData(compressionQuality: 0.3) else { return }
    
    STORAGE_PROFILE_IMAGE_REF.child(filename).putData(imageData, metadata: nil) { (metadata, error) in
      if let error = error {
        print("Fail to save user profile image",error.localizedDescription)
      }
      // 프로필 이미지 저장 경로
      let profileImageRef = STORAGE_PROFILE_IMAGE_REF.child(filename)
      profileImageRef.downloadURL(completion: { (url, error) in
        if let error = error {
          print("Fail to make profile Image URL", error.localizedDescription)
        } else {
          if let url = url {
            print("Profile ImageURL make!")
            print(url.absoluteString)
            
            USER_REF.child(currnetUid).child("profileImageUrl").setValue(url.absoluteString) { (err, ref) in
              guard let userProfileController = self.userProfileController else { return }
              userProfileController.fetchCurrentUserData()
              
              self.dismiss(animated: true, completion: nil)
            }
          }
        }
      })
    }
  }
  
  func updateUserName() {
    guard let updateUsername = self.updateUsername else { return }
    guard let currnetUid = Auth.auth().currentUser?.uid else { return }
    guard usernameChanged == true else { return }
    
    USER_REF.child(currnetUid).child("username").setValue(updateUsername) { (err, ref) in
      guard let userProfileController = self.userProfileController else { return }
      userProfileController.fetchCurrentUserData()
      
      self.dismiss(animated: true, completion: nil)
    }
  }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      profileImageView.image = selectedImage
      self.imageChanged = true
    }
    dismiss(animated: true, completion: nil)
  }
}

extension EditProfileController: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let user = self.user else { return }
    
    let trimmingString = usernameTextField.text?.replacingOccurrences(of: "\\s+S", with: "", options: .regularExpression)
    
    guard user.username != trimmingString else {
      print("Error: you did not change your username")
      usernameChanged = false
      return
    }
    
    guard trimmingString != "" else {
      print("ERror: input user name")
      usernameChanged = false
      return
    }
    
    self.updateUsername = trimmingString?.lowercased()
    usernameChanged = true
  }
}
