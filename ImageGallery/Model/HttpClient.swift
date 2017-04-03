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
    
    let baseUrl = "http://api.doitserver.in.ua"
    
    //  To get images using Token
    func getImages(tokenString:String, successCallback: @escaping ([Image]) -> (), errorCallback: @escaping (ApiError) -> ()) {
        
        let url = NSURL(string: self.baseUrl + "/all")!
        let request = NSMutableURLRequest(url: url as URL)
        
        do {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            request.addValue(tokenString, forHTTPHeaderField: "token")
        }
                
         let session = URLSession.shared
         let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            if(!self.isSuccessStatus(status: httpResponse.statusCode)) {
                errorCallback(self.parseError(data: data!)!)
                return
            }
            

                var successResponse = [Image]()

                    
                    do {
                        
                        let dictResult:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if let dictResultJSON = dictResult as? [String: AnyObject] {
                            if let imagesResultJSON = dictResultJSON["images"] as? [[String: AnyObject]] {
                                for imageJson in imagesResultJSON {
                                    let myImage = Image()
                                    myImage.id = imageJson["id"] as! Int
                                    myImage.bigImagePath = URL(string: imageJson["bigImagePath"] as! String)
                                    myImage.smallImagePath = URL(string: imageJson["smallImagePath"] as! String)
                                    if let imageParamets = imageJson["parameters"] as? [String: AnyObject]{

                                        if let imageAddress = imageParamets["address"] as? String{

                                            myImage.address = imageAddress
                                        }
                                        if let imageWeather = imageParamets["weather"] as? String{
                                            myImage.weather = imageWeather
                                        }
                                    }
                                    successResponse.append(myImage)
                                }
                                
                            }
                            
                        }
                        
                    } catch {
                        print("Error")
                    }


                successCallback(successResponse)
            }
        
        dataTask.resume()

    }
    
     //  To get gif using Token
    func getImagesGif(tokenString:String, successCallback: @escaping (UIImage) -> (), errorCallback: @escaping (ApiError) -> ()) {
        
        let url = NSURL(string: self.baseUrl + "/gif")!
        
        let request = NSMutableURLRequest(url: url as URL)
        do {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            request.addValue(tokenString, forHTTPHeaderField: "token")
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            if(!self.isSuccessStatus(status: httpResponse.statusCode)) {
                errorCallback(self.parseError(data: data!)!)
                return
            }
            
            // success, deserialize
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                let gifString = json?["gif"] as? String
                let img = UIImage.gifImageWithURL(gifUrl: gifString!)
                if img != nil {
                  successCallback(img!)
                }
            }
        }
        
        dataTask.resume()
    }
    
    func downloadImage(imageUrl:URL, successCallback: @escaping (UIImage) -> ()) {
        
        let request = NSMutableURLRequest(url: imageUrl)
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            successCallback(UIImage(data: data!)!)
        }
    
        dataTask.resume()
    }
    
    func isSuccessStatus(status:Int) -> Bool {
        return (status >= 200 && status < 300)
    }
    
    func parseError(data:Data) -> ApiError? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return ApiError(json: json!)!
        }
        return nil
    }

    //Log in (is user exist in system)
    func postLogIn(data:PostLoginRequest, successCallback: @escaping (PostLoginResponse) -> (), errorCallback: @escaping (ApiError) -> ()) {
        let url = NSURL(string: self.baseUrl + "/login")!
        let login = ["email":data.email, "password":data.password]
        let request = NSMutableURLRequest(url: url as URL)
        
        do {
            let auth = try JSONSerialization.data(withJSONObject: login, options: .prettyPrinted)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = auth
        } catch {
            print("Error")
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            if(!self.isSuccessStatus(status: httpResponse.statusCode)) {
                errorCallback(self.parseError(data: data!)!)
                return
            }
            
            // success, deserialize to PostLoginResponse
            let successResponse = PostLoginResponse()
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                print(json!)
                successResponse.token = (json?["token"] as? String)!
                successCallback(successResponse)
            }

        }
        
        dataTask.resume()
    }
    
    
    
    
    // Add new users
     func postUser(email:String, password:String, username:String, image: UIImage) -> NSMutableURLRequest {
        
        let url = NSURL(string: self.baseUrl + "/create")
        
        let request = NSMutableURLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        
        let param = [
            "email" : email,
            "password" : password,
            "username" : username
        ]
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        request.httpBody = createBodyWithParameters(parameters: param, imageKey: "avatar", imageData: imageData!, boundary: boundary)
        
        return request
        
    }

    
    //  Add images (using Token)
    func postImage(tokenString: String, image: UIImage, data:Image, successCallback: @escaping (Int) -> (), errorCallback: @escaping (ApiError) -> ()){
        
        let url = NSURL(string: self.baseUrl + "/image")
        let request = NSMutableURLRequest(url:url! as URL);
        
        do {
              request.httpMethod = "POST";
              request.addValue(tokenString, forHTTPHeaderField: "token")
              let param = [
                  "latitude"  : String(data.latitude),
                  "longitude"    : String(data.longitude),
                  "description" : data.description,
                  "hashtag": data.hashtag
              ] as [String : String]
             let boundary = generateBoundaryString()
             request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
             let imageData = UIImageJPEGRepresentation(image, 0.5)
             request.httpBody = createBodyWithParameters(parameters: param, imageKey: "image", imageData: imageData!, boundary: boundary)
    }
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            if(!self.isSuccessStatus(status: httpResponse.statusCode)) {
                errorCallback(self.parseError(data: data!)!)
                return
            }
            
                successCallback(1)
        }
        
        dataTask.resume()
        
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
