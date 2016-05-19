//
//  RemoteNotificationHandler.swift
//  yn
//
//  Created by Aurelien Prieur on 17/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import Alamofire

class RemoteNotificationHandler {
    class var sharedInstance: RemoteNotificationHandler {
        struct Static {
            static let instance: RemoteNotificationHandler = RemoteNotificationHandler()
        }
        return Static.instance
    }
    
    func registerDevice(deviceToken: String) throws {
        let apiHandler = ApiHandler.sharedInstance
        if apiHandler.isAuthenticated() {
            do {
                try apiHandler.request(.POST, URLString: ApiUrls.getUrl("registerDeviceForPushNotif"), parameters: [
                        "deviceToken": deviceToken
                    ], completion: { (result, err) in
                    if result != nil && err == nil {
                        print("registerDevice success")
                    }
                    else {
                        print("registerDevice failure: \(err)")
                    }
                })
            } catch let error as ApiError {
                print("Error: \(error)")
            } catch {
                print("An unexpected error has occured")
            }
            
        }
        else {
            throw RemoteNotificationError.RequireUserAuthentication
        }
    }
    
    func handleRemoteNotification(notification: [String: AnyObject], appState: UIApplicationState) {
        if let typeString = notification["type"] as? String {
            if let type = RemoteNotificationType(rawValue: typeString) {
                print("handleRemoteNotification. Type: \(type)")
                switch type {
                case .NewQuestion:
                    handleNewQuestion(notification)
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func handleNewQuestion(notification: [String: AnyObject]) {
        print("handleNewQuestion")
        print("notification.questionId: \(notification["questionId"])")
        if let questionId = notification["questionId"] as? Int {
            //if let questionId = Int(questionIdStr) {
                print("Send internal notification")
                NSNotificationCenter.defaultCenter().postNotificationName(InternalNotificationForRemote.newQuestion.rawValue, object: nil, userInfo: ["questionId": questionId])
            //}
        }
    }
}