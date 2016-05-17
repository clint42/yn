//
//  ApiHandler.swift
//  yn
//
//  Created by Aurelien Prieur on 02/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import Alamofire
import FBSDKLoginKit

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
                    else {
                        print(response.response?.statusCode)
                    }
                completion(false)
            }
        } catch let error as ApiError {
            print("Error: \(error)")
        } catch {
            print("Unexpected error")
        }
    }
    
    func authenticateWithFacebook(accessToken accessToken: FBSDKAccessToken, completion: (success: Bool, error: ApiError?) -> Void) {
        do {
            try Alamofire.request(.POST, ApiUrls.getUrl("fbSignin"), parameters: [
                "token": accessToken.tokenString,
                "userId": accessToken.userID,
                "appId": accessToken.appID
                ]).responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                    if response.result.isSuccess {
                        if let values = response.result.value as? Dictionary<String, AnyObject> {
                            if values["success"] as? Bool == true {
                                if let token = values["token"] as? String  {
                                    if let userId = values["userId"] as? Int {
                                        self.userToken = token
                                        self.userId = userId
                                        completion(success: true, error: nil)
                                        return
                                    }
                                }
                                completion(success: false, error: ApiError.ResponseInvalidData)
                            }
                            else if values["error"] != nil {
                                if values["error"] as? String == "userNotFound" {
                                    completion(success: false, error: ApiError.FBUserNotFound)
                                }
                                else {
                                    completion(success: false, error: ApiError.Unexpected)
                                }
                            }
                        }
                        else {
                            completion(success: false, error: ApiError.ResponseInvalidData)
                        }
                    }
                    else {
                        completion(success: false, error: ApiError.Unexpected)
                    }
                })
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
    
    func requestAnonymous(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String: AnyObject]?, completion: (result: Dictionary<String, AnyObject>?, err: ApiError?) -> Void) -> Request {
        return Alamofire.request(method, URLString, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).validate().responseJSON { (response) in
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
    
    func uploadMultiPartJpegImage(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String: String]?, images: [String: NSData]?, requestHandler: (request: Request?, error: ErrorType?) -> Void) throws {
        do {
            return try Alamofire.upload(method, URLString, headers: getAuthHeaders(), multipartFormData: { (multiFormData: MultipartFormData) in
                print("multipartFormData")
                if parameters != nil {
                    for (key, param) in parameters! {
                        if let paramData = param.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            multiFormData.appendBodyPart(data: paramData, name: key)
                        }
                        else {
                            print("An error occured while encoding param to NSDATA using NSUTF8StringEncoding")
                        }
                    }
                }
                if images != nil {
                    var index = 0
                    for (key, imageData) in images! {
                        print("name: \(key)")
                        multiFormData.appendBodyPart(data: imageData, name: key, fileName: "image\(index)", mimeType: "image/jpeg")
                        index += 1
                    }
                }
                }, encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold, encodingCompletion: { (encodingResult: Manager.MultipartFormDataEncodingResult) in
                    switch encodingResult {
                    case .Success(let request, _, _):
                        requestHandler(request: request, error: nil)
                        break
                    case .Failure(let error):
                        requestHandler(request: nil, error: error)
                        break
                    }
            })
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