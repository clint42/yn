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
    
    private var deviceToken: String?
    
    func registerDevice(deviceToken: String) throws {
        self.deviceToken = deviceToken
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
    
    func unregisterDevice() {
        let apiHandler = ApiHandler.sharedInstance
        if apiHandler.isAuthenticated() && deviceToken != nil {
            do {
                try apiHandler.request(.DELETE, URLString: ApiUrls.getUrl("unregisterDeviceForPushNotif"), parameters: [
                    "deviceToken": self.deviceToken!
                ], completion: { (result, err) in
                    if result != nil && err == nil {
                        print("unregisterDevice success")
                    }
                    else {
                        print("unregisterDevice failure: \(err)")
                    }
                })
            } catch let error as ApiError {
                print("Error: \(error)");
            } catch {
                print("An unexpected error has occured")
            }
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
                case .FriendRequest:
                    handleFriendRequest(notification)
                    break
                case .FriendshipAccepted:
                    handleFriendshipAccepted(notification)
                default:
                    break
                }
            }
        }
    }
    
    private func handleNewQuestion(notification: [String: AnyObject]) {
        if let questionId = notification["questionId"] as? Int {
            NSNotificationCenter.defaultCenter().postNotificationName(InternalNotificationForRemote.newQuestion.rawValue, object: nil, userInfo: ["questionId": questionId])
        }
    }
    
    private func handleFriendRequest(notification: [String: AnyObject]) {
        if let userId = notification["userId"] as? Int {
            NSNotificationCenter.defaultCenter().postNotificationName(InternalNotificationForRemote.friendRequest.rawValue, object: nil, userInfo: ["userId": userId])
        }
    }
    
    private func handleFriendshipAccepted(notification: [String: AnyObject]) {
        if let userId = notification["userId"] as? Int {
            NSNotificationCenter.defaultCenter().postNotificationName(InternalNotificationForRemote.friendshipAccepted.rawValue, object: nil, userInfo: ["userId": userId]);
        }
    }
}