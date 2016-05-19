//
//  Answer.swift
//  yn
//
//  Created by Julie FRANEL on 5/19/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import UIKit

class Answer {
    var id: Int
    var answer: String?
    var userId: Int
    var questionId: Int
    
    init(id: Int, answer: String, userId: Int, questionId: Int) {
        self.id = id
        self.answer = answer
        self.userId = userId
        self.questionId = questionId
    }
    
    convenience init(json: Dictionary<String, AnyObject>) throws {
        guard let id = json["id"] as? Int
            else {
                throw ApiError.ResponseInvalidData
        }
        guard let answer = json["answer"] as? String
            else {
                throw ApiError.ResponseInvalidData
        }
        guard let userId = json["UserId"] as? Int
            else {
                throw ApiError.ResponseInvalidData
        }
        guard let questionId = json["QuestionId"] as? Int
            else {
                throw ApiError.ResponseInvalidData
        }
        self.init(id: id, answer: answer, userId: userId, questionId: questionId);
    }
}
