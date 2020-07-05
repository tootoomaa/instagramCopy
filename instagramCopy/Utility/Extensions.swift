//
//  Extensions.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/04/30.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

extension UIColor {
  
  static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
  }
  
}

extension UIButton {
  
  func configure(didFollow: Bool) {
    
    if didFollow {
      // configure follow button
      self.setTitle("Following", for: .normal)
      self.setTitleColor(.black, for: .normal)
      self.layer.borderColor = UIColor.lightGray.cgColor
      self.layer.borderWidth = 0.5
      self.backgroundColor = .white
    } else {
      
      // configure Followed buttonm
      self.setTitle("Follow", for: .normal)
      self.setTitleColor(.white, for: .normal)
      self.layer.borderWidth = 0
      self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
  }
}




extension UIView {
  
  func anchor(
    top: NSLayoutYAxisAnchor?,
    left: NSLayoutXAxisAnchor?,
    bottom : NSLayoutYAxisAnchor?,
    right: NSLayoutXAxisAnchor?,
    paddingTop: CGFloat,
    paddingLeft: CGFloat,
    paddingBottom: CGFloat,
    paddingRight: CGFloat,
    width: CGFloat,
    height: CGFloat
  ) {
    
    translatesAutoresizingMaskIntoConstraints = false
    
    
    if let top = top {
      self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    if let left = left {
      self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    
    if let bottom = bottom {
      self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
    }
    
    if let right = right {
      self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    
    if width != 0 {
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    if height != 0 {
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
  }
}

//var imageCache = [String:UIImage]()

//extension UIImageView {
//    
//  func loadImage(with urlString: String) {
//    // 이미지가 케쉬 영역에 있는지 확인
//    if let cachedImage = imageCache[urlString] {
//      self.image = cachedImage
//      return
//    }
//    // 이미지가 케쉬 영역에 존제하지 않는 경우
//    guard let url = URL(string :urlString) else { return }
//    // 이미지 컨텐츠의 위치 얻기
//    URLSession.shared.dataTask(with: url) { (data, response, error ) in
//      if let error = error {
//        print("Failed to load image with error", error.localizedDescription)
//      }
//      
//      // 이미지 데이터 (NSData 타입)
//      guard let imageData = data else {return}
//      // 이미지 데이터를 통해서 이미지 생성 (Data -> image)
//      let photoImage = UIImage(data: imageData)
//      
//      //URL -> String값으로 변경하여 케쉬 변수에 저장
//      imageCache[url.absoluteString] = photoImage
//      DispatchQueue.main.sync {
//        self.image = photoImage
//      }
//    }.resume()
//  }
//}


extension Database {
  
  static func fetchUser(with uid:String, completion: @escaping(User) -> () ) {
    
    USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
      
      let user = User(uid: uid, dictionary: dictionary)
      
      completion(user)
    }
  }
  
  static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
    
    POSTS_REF.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
      guard let ownerUid = dictionary["ownerUid"] as? String else {return}
      
      Database.fetchUser(with: ownerUid) { (user) in
        let post = Post(postId: postId, user: user, dictionary: dictionary)
        
        completion(post)
      }
    })
  }
}
