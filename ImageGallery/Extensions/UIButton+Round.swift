//
//  UIButton+Round.swift
//  ImageGallery
//
//  Created by Katerina on 01.04.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
