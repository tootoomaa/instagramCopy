//
//  ChatCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/07/01.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class ChatCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .blue
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
