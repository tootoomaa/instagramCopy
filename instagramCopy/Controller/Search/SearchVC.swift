//
//  SearchVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController , UISearchBarDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  //MARK: - Properties
  
  var users = [User]()
  var filteredUsers = [User]()
  var searchBar = UISearchBar()
  var inSearchMode = false
  var collectionView: UICollectionView!
  var collectionViewEnabled = true
  var posts = [Post]()
  
  //MARK: - init
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //register cell classes
    tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
    
    // configure search bar
    configureSearchBar()
    
    // configure collection View
    configureCollectionView()
    
    // separator insets
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
    
    // fetch Posts
    fetchPosts()
    
    // fetch Users
    fetchUser()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    var user: User! // 임시 저장 변수
     if inSearchMode {
       user = filteredUsers[indexPath.row]  // 사용자가 입력한 스트링이 포함된 사용자 리스트
     } else {
       user = users[indexPath.row] // 전체 사용자 리스트
     }
    
    //create instance of user profileVC
    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
    
    // passes user from searchVc to userProfileVC
    userProfileVC.user = user
    
    // push view controller
    navigationController?.pushViewController(userProfileVC, animated: true)
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if inSearchMode {
      return filteredUsers.count
    } else {
      return users.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
    
    var user: User!
    if inSearchMode {
      user = filteredUsers[indexPath.row]
    } else {
      user = users[indexPath.row]
    }
     
    cell.user = user
    
    return cell
  }
  
  func configureSearchBar() {
    searchBar.sizeToFit()
    searchBar.delegate = self
    navigationItem.titleView = searchBar
    searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    searchBar.tintColor = .black
  }
  
  //MARK: - UICollectionView
  
  func configureCollectionView() {  // collectionView 설정 부분

    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical // 세로로 스크롤 적용
    
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)!-(navigationController?.navigationBar.frame.height)!)
    
    collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    
    tableView.addSubview(collectionView) // 이미 잡혀잇는 tableView에 넣기
    
    collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: "SearchPostCell")
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .white
    tableView.separatorColor = .clear
  }
  
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
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPostCell", for: indexPath) as! SearchPostCell
    
    cell.post = posts[indexPath.item]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
    feedVC.viewSinglePost = true
    feedVC.post = posts[indexPath.item]
    
    navigationController?.pushViewController(feedVC, animated: true)
  }
  
  
  //MARK: - UISearchBar
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
    
    // 사용자가 입력을 시작하면 collectionVeiw 숨김 처리
    collectionView.isHidden = true
    collectionViewEnabled = false
    
    tableView.separatorColor = .lightGray
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    // handle search text change
    
    let searchText = searchText.lowercased() // 사용자가 입력한 텍스트
    
    if searchText.isEmpty || searchText == " " {
      // 사용자가 입력을 취소한 경우
      inSearchMode = false
      tableView.reloadData()
    } else {
      // 사용자가 입력을 시작한 경우
      inSearchMode = true
      filteredUsers = users.filter({ (user) -> Bool in
        return user.username.lowercased().contains(searchText)
      })
      tableView.reloadData()
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    
    searchBar.showsCancelButton = false
    
    inSearchMode = false
    
    searchBar.text = nil
    
    collectionViewEnabled = true
    collectionView.isHidden = false
    
    tableView.separatorColor = .clear
    
    tableView.reloadData()
  }
  
  
  
  //MARK: - fetch User Data
  func fetchUser() {
    
    Database.database().reference().child("users").observe(.childAdded) { (snaphot) in
      
      // uid
      let uid = snaphot.key
      
      Database.fetchUser(with: uid, completion: { (user) in
        self.users.append(user)
        self.tableView.reloadData()
      })
    }
  }
  
  func fetchPosts() {
    posts.removeAll()
    
    POSTS_REF.observe(.childAdded) { (snapshot) in
      let postId = snapshot.key
      
      Database.fetchPost(with: postId, completion: { (post) in
        self.posts.append(post)
        self.collectionView.reloadData()
      })
    }
  }
}

