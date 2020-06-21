//
//  NewMessageCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/21.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class NewMessageCell: UITableViewCell {
  
  //MARK: - Properties
  
  var user: User? {
    
    didSet {
      guard let profileImageUrl = user?.profileImageUrl else { return }
      guard let useranem = user?.username else { return }
      guard let fullname = user?.name else { return }
      
      profileImageView.loadImage(with: profileImageUrl)
      textLabel?.text = useranem
      detailTextLabel?.text = fullname
      
    }
  }
  
  let profileImageView: CustomImageView = {
    let iv = CustomImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .lightGray
    return iv
  }()
  

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    profileImageView.layer.cornerRadius = 50/2
    profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    
    textLabel?.text = "Jocker"
    detailTextLabel?.text = "Heath Ledger"
  }
  
  override func layoutSubviews() {
    
    super.layoutSubviews()
    
    textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y-2 , width: textLabel!.frame.width, height: textLabel!.frame.height)
    
    detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y+2 , width: self.frame.width - 108, height: detailTextLabel!.frame.height)
    
    textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    
    detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    detailTextLabel?.textColor = .lightGray
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

}
