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
    
    func getFriends(completion: (users: [User], err: String?) -> Void) {
        do {
            try apiHandler.request(.GET, URLString: ApiUrls.getUrl("addFriend"), parameters: nil, completion: { (result, err) in
                print(result)
            })
        } catch let error as ApiError {
            print("Error: \(error)")
        } catch {
            print("Unexpected error")
        }
        
    }
    
}