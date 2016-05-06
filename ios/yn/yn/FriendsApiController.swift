//
//  FriendsApiController.swift
//  yn
//
//  Created by Aurelien Prieur on 04/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import Alamofire

class FriendsApiController {
    class var sharedInstance: FriendsApiController {
        struct Static {
            static let instance: FriendsApiController = FriendsApiController()
        }
        return Static.instance
    }
    
    private let apiHandler = ApiHandler.sharedInstance
    
    func getFriends(nResults nResults: Int, offset: Int, orderBy: String?, orderRule: String?, completion: (friends: [User]?, err: ApiError?) -> Void) throws -> Request {
        var params: [String: AnyObject] = [
            "nResults": nResults,
            "offset": offset
        ]
        if (orderBy != nil) {
            params["orderBy"] = orderBy!
        }
        if (orderRule != nil) {
            params["orderRule"] = orderRule!
        }
        do {
            return try apiHandler.request(.GET, URLString: ApiUrls.getUrl("myFriends"), parameters: params, completion: { (result, err) in
                var friends = [User]()
                if err == nil && result!["friends"] != nil && result!["friends"] is Array<Dictionary<String, AnyObject>> {
                    for user in result!["friends"] as! Array<Dictionary<String, AnyObject>> {
                        do {
                            try friends.append(User(json: user))
                        } catch let error as ApiError {
                            print("error: \(error)")
                        } catch {
                            print("Unexpected error")
                        }
                    }
                    completion(friends: friends, err: nil)
                }
                else if err != nil {
                    completion(friends: nil, err: ApiError.ResponseInvalidData)
                }
                else {
                    completion(friends: nil, err: err)
                }
            })
        }
    }
    
    func addFriend(userTargetIdentifier: String, completion: (success: Bool?, err: ApiError?) -> Void) throws -> Request {
        let params = [
            "identifier": userTargetIdentifier
        ]
        do {
            return try apiHandler.request(.POST, URLString: ApiUrls.getUrl("addFriend"), parameters: params, completion: { (result, err) in
                if err == nil {
                    completion(success: result!["success"] as? Bool, err: nil)
                }
                else {
                    completion(success: nil, err: err);
                }
            })
        }
    }
    
}