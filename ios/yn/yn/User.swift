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
    
    init(id: Int, username: String, email: String? = nil, phone: String? = nil, firstname: String? = nil, lastname: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.phone = phone
        self.firstname = firstname
        self.lastname = lastname
    }
    
    convenience init(json: Dictionary<String, AnyObject>) {
        self.init(id: 0, username: "test");
    }
}