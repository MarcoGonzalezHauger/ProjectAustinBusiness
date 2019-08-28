//
//  NetworkManager.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 19/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

class NetworkManager {

    static let sharedInstance = NetworkManager()
    
    func getClientTokenFromServer(completion: @escaping (_ status: String, _ error: String, _ dataValue: Data?) -> Void) {
        
        let urlString = API.kBaseURL + "getClientToken"
        
        let url: NSURL = NSURL(string: urlString)!
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil)
            }
            else{
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                completion("success", "",data!)
            }
            
        }
        
        task.resume()
        
        
        
    }
    
    func postNonceWithAmountToServer(params: [String: AnyObject],completion: @escaping (_ status: String, _ error: String?, _ dataValue: Data?) -> Void) {
        
        let urlString = API.kBaseURL + "postNonceToServer"
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil)
            }
            else{
//                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                completion("success",nil,data!)
            }
            
        }
        
        task.resume()
        
    }
    
    
    
}
