//
//  QuestionsApiController.swift
//  yn
//
//  Created by Grégoire Lafitte on 5/17/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import Alamofire

class QuestionsApiController {
    class var sharedInstance: QuestionsApiController {
        struct Static {
            static let instance: QuestionsApiController = QuestionsApiController()
        }
        return Static.instance
    }
    
    private let apiHandler = ApiHandler.sharedInstance
    
    func getQuestionsAsked(nResults nResults: Int, offset: Int, orderBy: String?, orderRule: String?, completion: (questions: [Question]?, err: ApiError?) -> Void) throws -> Request {
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
            return try apiHandler.request(.GET, URLString: ApiUrls.getUrl("getQuestionsAsked"), parameters: params, completion: { (result, err) in
                var questions = [Question]()
                if err == nil && result!["questions"] != nil && result!["questions"] is Array<Dictionary<String, AnyObject>> {
                    for question in result!["questions"] as! Array<Dictionary<String, AnyObject>> {
                        do {
                            try questions.append(Question(json: question))
                        } catch let error as ApiError {
                            print("error: \(error)")
                        } catch {
                            print("Unexpected error")
                        }
                    }
                    completion(questions: questions, err: nil)
                }
                else if err != nil {
                    completion(questions: nil, err: ApiError.ResponseInvalidData)
                }
                else {
                    completion(questions: nil, err: err)
                }
            })
        }
    }
    
    func getAllQuestions(nResults nResults: Int, offset: Int, orderBy: String?, orderRule: String?, completion: (result: [String:AnyObject]?, err: ApiError?) -> Void) throws -> Request {
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
            return try apiHandler.request(.GET, URLString: ApiUrls.getUrl("getAllQuestions"), parameters: params, completion: { (result, err) in
                var questions = [Question]()
                if err == nil && result!["questions"] != nil && result!["questions"] is Array<Dictionary<String, AnyObject>> {
                    for question in result!["questions"] as! Array<Dictionary<String, AnyObject>> {
                        do {
                            try questions.append(Question(json: question))
                        } catch let error as ApiError {
                            print("error: \(error)")
                        } catch {
                            print("Unexpected error")
                        }
                    }
                    let res: [String: AnyObject] = [
                        "questions": questions,
                        "userid": result!["userId"]!
                    ]
                    completion(result: res, err: nil)
                }
                else if err != nil {
                    completion(result: nil, err: ApiError.ResponseInvalidData)
                }
                else {
                    completion(result: nil, err: err)
                }
            })
        }
    }
    
    func answerToQuestion(questionId: Int, answer: Bool, completion: (success: Bool?, err: ApiError?) -> Void) throws -> Request {
        let params: [String: AnyObject] = [
            "identifier": questionId,
            "answer": answer
        ]
        do {
            return try apiHandler.request(.POST, URLString: ApiUrls.getUrl("answerTo"), parameters: params, completion: { (result, err) in
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