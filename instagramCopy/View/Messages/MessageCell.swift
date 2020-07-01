//
//  MessageCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/06/21.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

  //MARK: - Properties
  
  let profileImageView: CustomImageView = {
      let iv = CustomImageView()
      iv.contentMode = .scaleAspectFill
      iv.clipsToBounds = true
      iv.backgroundColor = .lightGray
      return iv
  }()
  
  let timeStampLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = .darkGray
    label.text = "2h"
    return label
  }()
  
  //MARK: - Init
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
    selectionStyle = .none
    
    addSubview(profileImageView)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    profileImageView.layer.cornerRadius = 50/2
    profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    addSubview(timeStampLabel)
    timeStampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    
    textLabel?.text = "Kocker"
    detailTextLabel?.text = "some test label to see if this work"
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
