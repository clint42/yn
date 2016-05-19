//
//  Question.swift
//  yn
//
//  Created by Grégoire Lafitte on 5/17/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import UIKit

class Question {
    var id: Int
    var title: String
    var description: String?
    var imageUrl: String?
    var ownerId: Int
    
    init(id: Int, title: String, description: String? = nil, image: String? = nil, ownerId: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = image
        self.ownerId = ownerId
    }
    
    convenience init(json: Dictionary<String, AnyObject>) throws {
        guard let id = json["id"] as? Int
            else {
                throw ApiError.ResponseInvalidData
        }
        guard let title = json["title"] as? String
            else {
                throw ApiError.ResponseInvalidData
        }
        self.init(id: id, title: title, description: json["question"] as? String, image: json["imageUrl"] as? String, ownerId: json["OwnerId"] as! Int);
    }
}