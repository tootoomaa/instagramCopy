//
//  SearchPostCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/21.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class SearchPostCell: UICollectionViewCell {
  
  var post: Post? {
    didSet {
      guard let imageUrl = post?.imageUrl else {return}
      postImageView.loadImage(with: imageUrl)
    }
  }
  
  let postImageView: CustomImageView = {
      let iv = CustomImageView()
      iv.contentMode = .scaleAspectFill
      iv.clipsToBounds = true
      iv.backgroundColor = .lightGray
      return iv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(postImageView)
    postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
