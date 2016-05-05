//
//  ApiUrls.swift
//  yn
//
//  Created by Aurelien Prieur on 04/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation

class ApiUrls {
    static private let path = NSBundle.mainBundle().pathForResource("ApiUrls", ofType: "plist");
    static private let dictionary = NSDictionary(contentsOfFile: path!)!;
    
    class func getUrl(key: String) throws -> String {
        if (dictionary["host"] != nil && dictionary[key] != nil) {
            return (dictionary["host"]! as! String) + (dictionary[key]! as! String);
        }
        else {
            throw ApiError.RouteNotDefined
        }
    }
}