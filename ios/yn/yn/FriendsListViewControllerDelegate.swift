//
//  FriendsListViewControllerDelegate.swift
//  yn
//
//  Created by Aurelien Prieur on 17/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

protocol FriendsListViewControllerDelegate {
    func friendsList(didSelectFriends friends: [User]?)
    func cancel()
}