//
//  User.swift
//  yn
//
//  Created by Aurelien Prieur on 02/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

class User {
    var id: Int
    var username: String
    var email: String?
    var phone: String?
    var firstname: String?
    var lastname: String?
    var fbId: String?
    
    init(id: Int, username: String, email: String? = nil, phone: String? = nil, firstname: String? = nil, lastname: String? = nil, fbId: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.phone = phone
        self.firstname = firstname
        self.lastname = lastname
        self.fbId = fbId
    }
    
    convenience init(json: Dictionary<String, AnyObject>) throws {
        guard let id = json["id"] as? Int
            else {
                throw ApiError.ResponseInvalidData
        }
        guard let username = json["username"] as? String
            else {
                throw ApiError.ResponseInvalidData
        }
        self.init(id: id, username: username, email: json["email"] as? String, phone: json["phone"] as? String, firstname: json["firstname"] as? String, lastname: json["lastname"] as? String, fbId: json["fbId"] as? String);
    }
}