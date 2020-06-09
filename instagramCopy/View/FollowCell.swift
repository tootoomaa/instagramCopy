//
//  FollowCell.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

class FollowCell: UITableViewCell {

    //MARK: - Properties
    var delegate: FollowCellDelegate?
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullname
            
            //자기 자신을 팔로우, 팔로잉을 못하도록 버튼 숨김
            if user?.uid == Auth.auth().currentUser?.uid {
                followButton.isHidden = true
            }
            
            user?.checkIfUserIsFollowed(completion: { (followed) in
                if followed {
                    // configure follow button
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.backgroundColor = .white
                } else {
                    // configure following button
                    self.followButton.setTitle("Followed", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                }
            })
            
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let followButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setTitle("Loading", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.layer.borderColor = CGColor(srgbRed: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        bt.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        bt.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        return bt
    }()
    
    
    //MARK: - handler
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    
    //MARK: - init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // add profile image View
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo : self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3
        followButton.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        
        self.textLabel?.text = "Username"
        self.detailTextLabel?.text = "Full Name"
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: (textLabel?.frame.origin.y)! - 2 , width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y , width: self.frame.width - 108, height: detailTextLabel!.frame.height)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .systemGray
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
