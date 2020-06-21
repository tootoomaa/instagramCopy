//
//  MainTabVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate{
  
  //MARK: - Properties
  var dot = UIView()
  var notificationIDs = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.delegate = self
    
    //configure view controller
    configureViewController()
    
    //configure view dot
    configureNotificationDot()
    
    //observer validation
    observeNotification()
    
    //user validation
    checkIfUserIsLoggedIn()
  }
  
  //MARK: - UITabBar
  // function to creat view controller that exist within tab bar controller
  func configureViewController() {
    
    // home feed controller
    let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
    // search feed controller
    let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
    
    // select Image Controller
    let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
    
    // post controller
    let uploadPostVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC())
    
    // notification Contoller
    let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationVC())
    
    // profile controller
    let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
    
    // view controller to be added to tab controller
    viewControllers = [feedVC, searchVC, selectImageVC , notificationVC, userProfileVC]
    
    //tab bar tint color
    tabBar.tintColor = .black
  }
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    let index = viewControllers?.firstIndex(of: viewController)
    
    if index == 2 {
      let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
      let navController = UINavigationController(rootViewController: selectImageVC)
      navController.navigationBar.tintColor = .black
      
      navController.modalPresentationStyle = .fullScreen
      present(navController, animated: true, completion: nil)
      return false
    } else if index == 3 {
      dot.isHidden = true
      return true
    }
    return true
  }
  
  /// Construct new controller
  func constructNavController(unselectedImage:UIImage, selectedImage:UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
    
    // Construct nav controller
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem.image = unselectedImage
    navController.tabBarItem.selectedImage = selectedImage
    navController.navigationBar.tintColor = .black
    
    // return new Controller
    return navController
  }
  
  
  func configureNotificationDot() {
    let tabBarHeight = tabBar.frame.height
    
    if UIDevice().userInterfaceIdiom == .phone {
      print(UIScreen.main.nativeBounds.height)
      if UIScreen.main.nativeBounds.height == 2436 {
        // configure dot for iphon x
        print("iphon x")
        dot.frame = CGRect(x: view.frame.size.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
        
      } else {
        // configure dot for other model
        print("iphon othres")
        dot.frame = CGRect(x: view.frame.size.width / 5 * 3, y: view.frame.height, width: 6, height: 6)
      }
      
      // creat dot
      dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
      dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha:1)
      self.view.addSubview(dot)
      dot.isHidden = false
      
    }
  }
  
  func checkIfUserIsLoggedIn(){
    DispatchQueue.main.async {
      if Auth.auth().currentUser == nil {
        print("Need to user Login")
        let loginVC = LoginVC()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
      } else {
        print("User Logined")
      }
      return
    }
  }
  
  //MARK: - API
  func observeNotification() {
    guard let currentUid = Auth.auth().currentUser?.uid else { return }
    self.notificationIDs.removeAll()
    
    NOTIFICATION_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
      guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
      allObject.forEach({ (snapshot) in
        
        let notificaitonId = snapshot.key
        
        NOTIFICATION_REF.child(currentUid).child(notificaitonId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
          
          guard let checked = snapshot.value as? Int else { return }
          if checked == 0 {
            self.dot.isHidden = false
          } else {
            self.dot.isHidden = true
          }
        })
      })
    }
  }
}
