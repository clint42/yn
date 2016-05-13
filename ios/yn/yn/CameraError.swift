//
//  CameraError.swift
//  yn
//
//  Created by Aurelien Prieur on 12/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

enum CameraError: ErrorType {
    case FrontCameraDoesNotExist
    case BackCameraDoesNotExist
    case UnknownError
}

extension CameraError: CustomStringConvertible {
    var description: String {
        switch self {
        case .FrontCameraDoesNotExist:
            return "Front camera is not available on your device"
        case .BackCameraDoesNotExist:
            return "Back camera is not available on your device"
        case .UnknownError:
            return "Camera unknwon error"
        }
    }
}