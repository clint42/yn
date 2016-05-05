//
//  ApiError.swift
//  yn
//
//  Created by Aurelien Prieur on 04/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

enum ApiError: ErrorType {
    case UserNotAuthenticated
    case RouteNotDefined
    case NetworkError
}

extension ApiError: CustomStringConvertible {
    var description: String {
        switch self {
        case .RouteNotDefined:
            return "Route is not defined"
        case .NetworkError:
            return "Network error"
        default:
            return "Unknown ApiError exception"
        }
    }
}