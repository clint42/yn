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
    case NotFound
    case MissingParameters
    case ResponseInvalidData
    case Unexpected
}

extension ApiError: CustomStringConvertible {
    var description: String {
        switch self {
        case .UserNotAuthenticated:
            return "User is not authenticated"
        case .RouteNotDefined:
            return "Route is not defined"
        case .NetworkError:
            return "Network error"
        case .NotFound:
            return "Route not found (HTTP 404)"
        case .MissingParameters:
            return "Missing parameter(s)"
        case .Unexpected:
            return "Unexpected error"
        case .ResponseInvalidData:
            return "Response received contains invalid data"
        }
    }
}