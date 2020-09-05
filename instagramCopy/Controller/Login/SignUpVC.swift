//
//  SingUpVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var imageSelected = false
    
    let plusPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTexField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()

    let fullNameTexField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let usernameTexField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: . touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let passwordTexField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "pasword"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Alreadt have an Account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString(string: "Sign in",attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14) ,NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha:1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        configureViewComponets()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)

    }
    
    func configureViewComponets() {
        let stackVeiw = UIStackView(arrangedSubviews: [emailTexField,fullNameTexField,usernameTexField,passwordTexField,signUpButton])
        
        stackVeiw.axis = .vertical
        stackVeiw.spacing = 10
        stackVeiw.distribution = .fillEqually
        
        view.addSubview(stackVeiw)
        stackVeiw.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //selected image
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        //set imageSelected true
        imageSelected = true
        
        //configure plusPhotoBtn with selected image
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelectProfilePhoto() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // preent imagePicker
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @objc func formValidation(_ sender: UITextField) {
        guard
            emailTexField.hasText,
            passwordTexField.hasText,
            fullNameTexField.hasText,
            usernameTexField.hasText,
            imageSelected == true
            else {
                signUpButton.isHidden = false
                signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 235/255, alpha: 1)
        
    }
    
    @objc func handleSignUp(_ sender:UIButton) {
        
        // properties
        guard let email = emailTexField.text else { return }
        guard let password = passwordTexField.text else { return }
        guard let fullName = fullNameTexField.text else { return }
        guard let userName = usernameTexField.text?.lowercased() else { return }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            //handle Error
            if let error = error {
                print("Fail to create user with error: ", error.localizedDescription)
                return
            }
            
            // set profile image
            guard let profileImg = self.plusPhotoButton.imageView?.image else { return }
            print("profileImg : \(profileImg)")
            
            // upload data
            guard let uploadDate = profileImg.jpegData(compressionQuality: 0.3) else { return }
            print("uploadDate : \(uploadDate)")
            
            //firebase 앱을 사용하여 스토리지 서비스를 가리키는 참조를 가져옵니다.
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            //place image in firebase storage
            let filename = NSUUID().uuidString // 파일 이름 생성
            print("make file name")
            storageRef.child("profile_image").child(filename).putData(uploadDate, metadata: nil) { (metadata, error) in
                
                
                if let error = error {
                    print("Failed to upload image to Firebase Storage with error.", error.localizedDescription)
                }
                
                // 프로필 이미지 저장 경로
                let profileImageRef = storageRef.child("profile_image").child(filename)
                print(profileImageRef)
                print("Before Profile ImageURL make!")
                profileImageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print("Fail to make profile Image URL", error.localizedDescription)
                    } else {
                        if let url = url {
                            print("Profile ImageURL make!")
                            print(url.absoluteString)
                            
                            let dictionaryValues = [
                                "name" : fullName,
                                "username" : userName,
                                "profileImageUrl" : url.absoluteString
                            ]
                            print("Before Make User information")
                            guard let user = user else { return }
                            print("Complete Make User Information")
                            print(user)
                            //데이터베이스에 저장할 사용자 정보 생성
                            let values = [user.user.uid: dictionaryValues]
                            print("input Data Create Complete")
                            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                                print("Success to Updata Database User Informagion")
                            })
                        }
                    }
                    
                })
            }
            //success
            print("Successfully created user with Firebase")
        }
    }
    
    @objc func handleShowLogin(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
