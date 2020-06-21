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
    
    func handleFollowTapped(for cell: FollowLikeCell)
}


protocol FeedCellDelegate {
  func handleUsernameTapped(for cell: FeedCell)
  func handleOptionTapped(for cell: FeedCell)
  func handleLikeTapped(for cell: FeedCell, isDoubleTap:Bool)
  func handleCommentTapped(for cell: FeedCell)
  func handleConfigureLikeButton(for cell: FeedCell)
  func handleShowLikes(for cell: FeedCell)
  func handleDoubleTapToLike(for cell: FeedCell)
}

protocol printable {
  var description: String { get }
}


protocol NotificationCellDelegate {
  func handleFollowTapped(for cell: NotificationCell)
  func handlePostTapped(for cell: NotificationCell)
}
