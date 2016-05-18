//
//  RemoteNotificationError.swift
//  yn
//
//  Created by Aurelien Prieur on 17/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

enum RemoteNotificationError: ErrorType {
    case RequireUserAuthentication
}

extension RemoteNotificationError: CustomStringConvertible {
    var description: String {
        switch self {
            case RequireUserAuthentication:
                return "User must be authenticated"
        }
    }
}