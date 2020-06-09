//
//  Protocols.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/05/24.
//  Copyright © 2020 김광수. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowCell)
}

