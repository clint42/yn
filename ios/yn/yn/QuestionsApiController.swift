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
            "questionId": questionId,
            "answer": answer
        ]
        do {
            return try apiHandler.request(.POST, URLString: ApiUrls.getUrl("answerToQuestion"), parameters: params, completion: { (result, err) in
                if err == nil {
                    completion(success: result!["success"] as? Bool, err: nil)
                }
                else {
                    completion(success: nil, err: err);
                }
            })
        }
    }
    
    func getQuestion(questionId: Int, completion: (question: Question?, err: ApiError?) -> Void) throws -> Request {
        do {
            return try apiHandler.request(.GET, URLString: ApiUrls.getUrl("getQuestion") + "/\(questionId)", parameters: nil, completion: {
                (result, err) in
                if err == nil {
                    if let questionJson = result!["question"] as? Dictionary<String, AnyObject> {
                        print(questionJson)
                        do {
                            try completion(question: Question(json: questionJson), err: nil)
                        } catch let error as ApiError {
                            completion(question: nil, err: error)
                        } catch {
                            completion(question: nil, err: ApiError.Unexpected)
                        }
                    }
                }
                else {
                    completion(question: nil, err: err)
                }
            })
        }
    }
    
    func getQuestionDetails(questionId: Int, completion: (questionDetails: [String:AnyObject]?, err: ApiError?) -> Void) throws -> Request {
        do {
            return try apiHandler.request(.GET, URLString: ApiUrls.getUrl("getQuestionDetails") + "/\(questionId)", parameters: nil, completion: {
                (questionDetails, err) in
                //print(questionDetails!)
                if err == nil {
                    do {
                        let questionJson = questionDetails!["question"] as? Dictionary<String, AnyObject>
                        var answers = [Answer]()
                        for answer in (questionDetails!["answers"] as? NSArray)! {
                            let q = try Answer(json: answer as! Dictionary<String, AnyObject>)
                            answers.append(q)
                        }
                        let questions = try Question(json: questionJson!)
                        let params: [String: AnyObject] = [
                                "question": questions,
                                "answers": answers
                            ]
                        completion(questionDetails: params, err: nil)
                    } catch let error as ApiError {
                        completion(questionDetails: nil, err: error)
                    } catch {
                        completion(questionDetails: nil, err: ApiError.Unexpected)
                    }
                }
                else {
                    completion(questionDetails: nil, err: err)
                }
            })
        }
    }
}