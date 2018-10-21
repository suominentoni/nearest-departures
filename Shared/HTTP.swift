//
//  HTTP.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

open class HTTP {
    fileprivate func getJSONObject(
        _ url: String,
        callback: @escaping ([String: AnyObject], String?) -> Void) -> Void {
            NSLog("HTTP GET: " + url)
            let request = NSMutableURLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback([String: AnyObject](), error)
                } else {
                    let jsonObj: [String: AnyObject]
                    jsonObj = self.JSONParseDict(data)
                    callback(jsonObj, nil)
                }
            }
    }

    func post(
        _ url: String,
        body: String,
        callback: @escaping ([String: AnyObject], String?) -> Void) -> Void {
            NSLog("HTTP POST: " + url)
            let request = NSMutableURLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/graphql", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = body.data(using: String.Encoding.utf8)
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback([String: AnyObject](), error)
                } else {
                    let jsonObj: [String: AnyObject]
                    jsonObj = self.JSONParseDict(data)
                    callback(jsonObj, nil)
                }
            }
    }

    fileprivate func getJSONArray(
        _ url: String,
        callback: @escaping ([AnyObject], String?) -> Void) -> Void {
            let request = NSMutableURLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback([AnyObject](), error)
                } else {
                    let jsonObj:[AnyObject]
                    jsonObj = self.JSONParseArray(data)
                    callback(jsonObj, nil)
                }
            }
    }

    fileprivate func JSONParseArray(_ jsonString:String) -> [AnyObject] {
        if let data: Data = jsonString.data(
            using: String.Encoding.utf8){
                do{
                    if let jsonObj = try JSONSerialization.jsonObject(
                        with: data,
                        options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [AnyObject]{
                            return jsonObj
                    }
                }catch{
                    NSLog("Error parsing JSON")
                }
        }
        return [AnyObject]()
    }

    fileprivate func JSONParseDict(_ jsonString:String) -> [String: AnyObject] {
        if let data: Data = jsonString.data(
            using: String.Encoding.utf8){
                do{
                    if let jsonObj = try JSONSerialization.jsonObject(
                        with: data,
                        options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject]{
                            return jsonObj
                    }
                }catch{
                    NSLog("Error parsing JSON")
                }
        }
        return [String: AnyObject]()
    }

    func HTTPsendRequest(_ request: NSMutableURLRequest,
        callback: @escaping (String, String?) -> Void) -> Void {
            let task = URLSession.shared.dataTask(
                with: request as URLRequest, completionHandler :
                {
                    data, response, error in
                    if error != nil {
                        NSLog("Error sending http request: \(error!)")
                        callback("", (error!.localizedDescription) as String)
                    } else {
                        callback(
                            String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!,
                            nil
                        )
                    }
            })
            task.resume()
    }
}
