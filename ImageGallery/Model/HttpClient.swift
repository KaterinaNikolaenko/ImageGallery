//
//  HttpClient.swift
//  ImageGallery
//
//  Created by Katerina on 26.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import Foundation
import UIKit

class HttpClient {
    
    func getImages(tokenString:String) -> NSMutableURLRequest {
        
        let urlLogin = NSURL(string: "http://api.doitserver.in.ua/gif")!
        
        
        let request = NSMutableURLRequest(url: urlLogin as URL)
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "GET"
            
            request.addValue(tokenString, forHTTPHeaderField: "token")
        
        
        return request
        
        
    }
    
    func postLogIn(email:String, password:String) -> NSMutableURLRequest {
        
        let urlLogin = NSURL(string: "http://api.doitserver.in.ua/login")!
        
         let login = ["email":email, "password":password]
        
        
        let request = NSMutableURLRequest(url: urlLogin as URL)
        
        do {
            
            let auth = try JSONSerialization.data(withJSONObject: login, options: .prettyPrinted)
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            
            request.httpBody = auth
            
          }catch {
    
               print("Error")
        
           }
        
        return request
     }
    
     func postUser(email:String, password:String, username:String, image: UIImage) -> NSMutableURLRequest {
        
        let myUrl = NSURL(string: "http://api.doitserver.in.ua/create")
        
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        
        //request.addValue(tokenString, forHTTPHeaderField: "token")
        
        
        let param = [
            "email" : email,
            "password" : password,
            "username" : username
        ]
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        
        // if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, imageKey: "image", imageData: imageData!, boundary: boundary)
        
        return request
        
    }
    
    
    func postImage(latitude:String, longitude:String, description:String, tokenString:String, image: UIImage) -> NSMutableURLRequest {
        
        let myUrl = NSURL(string: "http://api.doitserver.in.ua/image")
        
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        
        request.addValue(tokenString, forHTTPHeaderField: "token")
        
        
        let param = [
            "latitude"  : latitude,
            "longitude"    : longitude,
            "description" : description
        ]
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        
       // if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, imageKey: "image", imageData: imageData!, boundary: boundary)
        
        return request
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, imageKey: String, imageData: Data, boundary: String) -> Data {
        let body = NSMutableData();
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: boundaryPrefix)
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: boundaryPrefix)
        body.appendString(string: "Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageData)
        body.appendString(string: "\r\n")
        
        body.appendString(string: boundaryPrefix + "--")
        
        return body as Data
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
