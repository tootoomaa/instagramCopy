//
//  LoginVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/04/30.
//  Copyright © 2020 김광수. All rights reserved.
//
    
import UIKit
import Firebase

class LoginVC: UIViewController {
    
    let logoContainerview: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        return view
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
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an Account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSMutableAttributedString(string: "Sign up",attributes:  [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14) ,NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha:1)]))
        //red: 17/255, green: 154/255, blue: 237/255
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //backgroundColor
        view.backgroundColor = .white
        
        //hide nav bar
        navigationController?.navigationBar.isHidden = true
//        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(logoContainerview)
        logoContainerview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        configureViewComponets()
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        
    }
    
    @objc func formValidation() {
        
        //ensure Id PW is not void
        guard
            emailTexField.hasText,
            passwordTexField.hasText
        else {
                //handle case for above condition not met
                loginButton.isHidden = false
                loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        // handle case for condition met
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 235/255, alpha: 1)
    }
    
    @objc func handleSignIn() {
        
        //check user Information
        guard
            let email = emailTexField.text,
            let password = passwordTexField.text else { return }
        
        //sign user  in with email , password
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            //handle Error
            if let error = error {
                print("Unable to SignIn", error.localizedDescription)
                return
            }
            
            //handle success
            print("Sucessful Signup user Login")
            
//            let mainTabVC = MainTabVC()                   // 기존
//            self.present(mainTabVC, animated: true)       // 기존
            
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
            mainTabVC.configureViewController()
            self.dismiss(animated:true, completion:nil)
//            self.present(mainTabVC, animated: true)
            
        }
    }
    
    @objc func handleShowSignUp(_ sender:UIButton) {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func configureViewComponets() {
        let stackVeiw = UIStackView(arrangedSubviews: [emailTexField,passwordTexField,loginButton])
        
        stackVeiw.axis = .vertical
        stackVeiw.spacing = 10
        stackVeiw.distribution = .fillEqually
        
        view.addSubview(stackVeiw)
        stackVeiw.anchor(top: logoContainerview.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
        
    }
}
