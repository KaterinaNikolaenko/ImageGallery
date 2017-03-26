//
//  PopUpViewController.swift
//  ImageGallery
//
//  Created by Katerina on 26.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit
import ImageIO

class PopUpViewController: UIViewController {
    
    var tokenString:String = UserDefaults.standard.string(forKey: "token")!
    
    @IBOutlet weak var imagePopUp : UIImageView!
    var imageGif : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getGifImages()
    
        //self.imagePopUp.setGifImage(self.imageGif!, manager: SwiftyGifManager.defaultManager)
        //self.showAnimate()
    }

    func getGifImages(){
        
        var gifString = ""
        
        let session = URLSession.shared
        let httpClient = HttpClient()
        let task = session.dataTask(with: (httpClient.getImages(tokenString: tokenString)) as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error!)
                
            }
            else {
                
                if data != nil {
                    
                    do {
                        
                        let dictResult:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if (dictResult["error"] as? String) != nil {
                            print("error1")
                            print(dictResult)
                            
                        } else
                            
                        {
                            
                            print(dictResult)
                            gifString = (dictResult["gif"] as? String)!
                            DispatchQueue.main.async {
                                self.imageGif = UIImage.gifImageWithURL(gifUrl: gifString)
                                
                                //self.imagePopUp.setGifImage(self.imageGif!, manager: SwiftyGifManager.defaultManager)
                                self.imagePopUp.image = self.imageGif!
                                //self.imagePopUp.startAnimatingGif()
                            }
                           UserDefaults.standard.synchronize()
                            
                        }
                        
                    } catch {
                        print("Error")
                    }
                }
                
            }
            
        })
        
        task.resume()
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        
        self.view.removeFromSuperview()
        self.removeAnimate()
    }
    
    func showAnimate()  {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished : Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }
    

}
