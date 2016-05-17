//
//  ApiHandler.swift
//  yn
//
//  Created by Aurelien Prieur on 02/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import Alamofire

class ApiHandler {
    class var sharedInstance: ApiHandler {
        struct Static {
            static let instance: ApiHandler = ApiHandler()
        }
        return Static.instance
    }
    
    private var userToken: String?
    private var userId: Int?
    
    private var identifier: String?
    private var password: String?
    
    private func getAuthHeaders() throws -> [String: String] {
        if (userToken != nil && userId != nil) {
            return ["x-access-token": userToken!, "x-user-id": "\(userId!)"]
        }
        else {
            throw ApiError.UserNotAuthenticated
        }
    }
    
    func authenticate(identifier identifier: String, password: String, completion: (Bool) -> Void) {
        self.identifier = identifier
        self.password = password
        do {
            try Alamofire.request(.POST, ApiUrls.getUrl("signin"), parameters: [
                "identifier": identifier,
                "password": password
                ]).responseJSON { (response) in
                    if response.result.isSuccess {
                        if let token = response.result.value!["token"] as? String {
                            if let userId = response.result.value!["userId"] as? Int {
                                self.userToken = token
                                self.userId = userId
                                completion(true)
                                return
                            }
                        }
                    }
                completion(false)
            }
        } catch let error as ApiError {
            print("Error: \(error)")
        } catch {
            print("Unexpected error")
        }
    }
    
    func request(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String: AnyObject]?, completion: (result: Dictionary<String, AnyObject>?, err: ApiError?) -> Void) throws -> Request {
            return try Alamofire.request(method, URLString, parameters: parameters, encoding: ParameterEncoding.URL, headers: getAuthHeaders()).validate().responseJSON { (response) in
                if response.result.isSuccess {
                    completion(result: response.result.value as? Dictionary<String, AnyObject>, err: nil)
                }
                else if let response = response.response {
                    switch response.statusCode {
                    case 404:
                        completion(result: nil, err: ApiError.NotFound)
                    case 422:
                        completion(result: nil, err: ApiError.MissingParameters)
                    default:
                        completion(result: nil, err: ApiError.Unexpected)
                    }
                }
            }
    }
    
    //TODO: Re-implement this request method (does not work) as the one above ^
    func request(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String: AnyObject]?, encoding: ParameterEncoding, headers: [String: String]?, completion: (result: Array<Dictionary<String, AnyObject>>?, err: String?) -> Void) {
        Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                completion(result: response.result.value as? Array<Dictionary<String, AnyObject>>, err: nil)
            }
        }
    }
    func logout() {
        userToken = nil
        password = nil
    }
}