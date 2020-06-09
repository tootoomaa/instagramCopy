//
//  UserProfileHeader.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/06.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            //버튼의 속성을 정의해주는 함수
            configureProfileFollowButton()
            
            // set user stats
            setUserStats(for: user)
            
            let fullname = user?.name
            nameLabel.text = fullname
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(with: profileImageUrl)
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "follows", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTouchesRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
               attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
               label.attributedText = attributedText
        
        // add gesture recognizer
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFolloweringTapped))
        followingTap.numberOfTouchesRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followingTap)
        
        return label
    }()
    
    let editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading..", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    
    //MARK: - Handler
    

    @objc func handleFollowersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }

    @objc func handleFolloweringTapped() {
        delegate?.handleFollowingTapped(for: self)
    }
    
    @objc func handleEditProfileFollow() {
        delegate?.handleEditFollowTapped(for: self) 
    }
    
    func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
    }

    func configureBottonToolBar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func configureProfileFollowButton() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        if currentUid == user.uid {
            //configure Button as edit profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            
        } else {
            
            //configure button as follow btton
            editProfileFollowButton.layer.borderColor = CGColor(srgbRed: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
            // 앱의 안전성을 확보하기 위해서 이전 연결이 완료된 후에 실행되도록 하는 안전장치 ex)데이터 받아오기 등등
            // followed는 API를 통해서 결정되기 때문에 시간이 조금 길어질 수도 있다.
            user.checkIfUserIsFollowed (completion: { (followed) in
                if followed {
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                } else {
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
            })
        }
    }

    func configureUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        // User prifile information add
        configureUserStats()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
        
        configureBottonToolBar()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init{coder:} has note been impemented")
    }
}
