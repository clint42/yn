//
//  RemoteNotificationType.swift
//  yn
//
//  Created by Aurelien Prieur on 18/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

enum RemoteNotificationType: String {
    case NewQuestion = "newQuestion"
    case NewAnswer = "newAnswer"
    case FriendRequest = "friendRequest"
    case FriendshipAccepted = "friendshipAccepted"
}