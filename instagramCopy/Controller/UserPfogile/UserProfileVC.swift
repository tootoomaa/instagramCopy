//
//  UserProfileVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {

    //MARK: - Properties
    
    var currentUser: User? //searchVC에서 정보 받음
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Properties
        // Register cell classes
        // collectionView의 일반 Cell 표시
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // collectionView의 Header를 표시
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //backgtound color
        self.collectionView.backgroundColor = .white
        
        // fetch user Data (search뷰에서 불러온 화면은 currnetUser데이터를 가지고 있음)
        if self.currentUser == nil {
            // tabBarButton상의 profile누를 때 처리
            fetchCurrentUserData() // 현제 접속된 사용자의 정보 받아옴
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // collectionVeiw 를 통해서 보여줄 아이탬 갯수
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Header 정의
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        // delegate Declare
        header.delegate = self
        
        // set Header file
        header.user = self.currentUser
        navigationItem.title = currentUser?.username
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //header의 크기 지정
        return CGSize(width: view.frame.width - 30 * 2, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        // cell의 모양 및 크키 등을 지정
        
        return cell
    }
    
    //MARK: - UserProfileHeader Protocols
    // curruntUser (search뷰에서 불러온 화면은 currnetUser데이터를 가지고 있음)
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowVC()
        followVC.uid = currentUser?.uid
        followVC.viewFollowers = true
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowVC()
        followVC.uid = currentUser?.uid
        followVC.viewFollowers = false
//        followVC.viewFollowing = true
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }
        
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {
            print("Edir Profile")
        } else {
            
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        
        guard let uid = header.user?.uid else { return }
        
        var numberOfFollowers:Int!
        var numberOfFollowing:Int!
        
        // get number of following
        // observe - > DB에 변화가 있을 경우 즉시 갱싱
        // observeSingleEvent -> DB에서 한번만 가져옴
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followersLabel.attributedText = attributedText
        }
        
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            // get number of followed
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "Following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followingLabel.attributedText = attributedText
        }
        
    }
    
    //MARK - API
    func fetchCurrentUserData() {
        //get user data
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionanry = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionanry)
            self.currentUser = user

            self.navigationItem.title = self.currentUser?.name
            self.collectionView.reloadData()
        }
    }
}

