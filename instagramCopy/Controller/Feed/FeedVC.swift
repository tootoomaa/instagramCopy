//
//  FeedVC.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/04.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController {

    
    //MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // configure logour Button
        configLogoutButton()
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: Handlers
    
    func configLogoutButton() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
    }
    
    @objc func handleLogout() {
        //declare slert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //add alert action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive  ,handler: { (_) in
            do {
                // attemp sign out
                try Auth.auth().signOut()
                
                //present login controller
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                print("SucessFull Log out User")
            } catch {
                //handle erorr
                print("Failed to sign out")
            }
        }))
        // configure Alert Button 
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
