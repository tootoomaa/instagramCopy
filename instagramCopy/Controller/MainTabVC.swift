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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        //configure view controller 
        configureViewController()
        
        //user validation
        checkIfUserIsLoggedIn()
    }
    
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
}
