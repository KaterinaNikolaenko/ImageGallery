//
//  ImageCellCollectionView.swift
//  ImageGallery
//
//  Created by Katerina on 02.04.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit

class ImageCellCollectionView: UICollectionViewCell {
    
    @IBOutlet weak var imageCustomCell: UIImageView!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
