//
//  UsersApiController.swift
//  yn
//
//  Created by Aurelien Prieur on 06/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import Alamofire

class UsersApiController {
    class var sharedInstance: UsersApiController {
        struct Static {
            static let instance: UsersApiController = UsersApiController()
        }
        return Static.instance
    }
    
    private let apiHandler = ApiHandler.sharedInstance
    
    func searchByIdentifier(searchStmt: String, completion: ([User]?, err: ApiError?) -> Void) throws -> Request {
        let params = [
            "searchString": searchStmt
        ]
        var users = [User]()
        do {
            return try apiHandler.request(.GET, URLString: ApiUrls.getUrl("searchUsers"), parameters: params) { (result, err) in
                if err == nil && result!["users"] != nil && result!["users"] is Array<Dictionary<String, AnyObject>> {
                    for user in result!["users"] as! Array<Dictionary<String, AnyObject>> {
                        do {
                            try users.append(User(json: user))
                        } catch let error as ApiError {
                            print("error: \(error)")
                        } catch {
                            print("Unexpected error")
                        }
                    }
                    completion(users, err: nil)
                }
                else if err != nil {
                    completion(nil, err: ApiError.ResponseInvalidData)
                }
                else {
                    completion(nil, err: err)
                }
            }
        }
    }

}