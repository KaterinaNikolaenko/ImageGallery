//
//  ApiError.swift
//  ImageGallery
//
//  Created by Katerina on 01.04.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import Foundation

struct ApiError {
    let error:String
}

extension ApiError {
    init?(json: [String: Any]) {
        guard let
            error = json["error"] as? String
        else {
                return nil
        }
        
        self.error = error
    }
}
