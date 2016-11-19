//
//  Router.swift
//
//  Created by Seyhun Akyürek on 01/10/2016.
//  Copyright © 2016 seyhunak. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Router

protocol RouterProtocol {
    var apiType: ApiType { get set }
    func post() -> String
    func get(identifier: String) -> String
    func update(identifier: String) -> String
    func destroy(identifier: String) -> String
}

enum Router<T where T: RouterProtocol>: URLRequestConvertible {

    case post(T, [String: AnyObject])
    case get(T, String)
    case update(T, String, [String: AnyObject])
    case destroy(T, String)
    
    var method: Alamofire.Method {
        switch self {
        case .post:
            return .POST
        case .get:
            return .GET
        case .update:
            return .PUT
        case .destroy:
            return .DELETE
        }
    }
    
    var path: NSURL {
        switch self {
        case .post(let object, _):
            return object.apiType.path
        case .get(let object):
            return object.0.apiType.path
        case .update(let object):
            return object.0.apiType.path
        case .destroy(let object):
            return object.0.apiType.path
        }
    }
    
    var route: String {
        switch self {
        case .post(let object, _):
            return object.post()
        case .get(let object, let identifier):
            return object.get(identifier)
        case .update(let object, let identifier, _):
            return object.update(identifier)
        case .destroy(let object, let identifier):
            return object.destroy(identifier)
        }
    }
    
    // MARK: - URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let task = NSURLSession.sharedSession().dataTaskWithURL(path) {
            (data, response, error) in
            if error != nil {
                return
            }
        }
        
        task.resume()

        let mutableURLRequest = NSMutableURLRequest(URL: path.URLByAppendingPathComponent(route))
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.timeoutInterval = NSTimeInterval(10 * 1000)
    
        if let token = oauthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            mutableURLRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        switch self {
        case .post(_, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .update(_, _, let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        default:
            return mutableURLRequest
        }
    }
}
