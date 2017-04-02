//
//  ListOfImagesVC.swift
//  ImageGallery
//
//  Created by Katerina on 25.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit

class ListOfImagesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
 
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var tokenString:String = UserDefaults.standard.string(forKey: "token")!
    var galleryImagess = [Image()]
    var imageGif : UIImage?
    var effect:UIVisualEffect!
    
    @IBOutlet weak var imagePopUp: UIImageView!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "ImageCellCollectionView", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
   
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
    
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        popupView.layer.cornerRadius = 5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getImagess()
        self.collectionView!.reloadData()
    }
    
    func animateIn() {
        self.view.addSubview(popupView)
        popupView.center = self.view.center
        popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        popupView.alpha = 0.0
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.popupView.alpha = 1.0
            self.popupView.transform = CGAffineTransform.identity
        }
        getGifImages()
    }
    
    @IBAction func dismissPopUp(_ sender: Any) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
        removeAnimate()
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.popupView.alpha = 0.0
        }) { (finished : Bool) in
            if (finished) {
                self.popupView.removeFromSuperview()
            }
        }
    }
    
    // Get GIF using Token
    func getGifImages(){
        
        var gifString = ""
        
        activityIndicator.center = popupView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        let session = URLSession.shared
        let httpClient = HttpClient()
        let task = session.dataTask(with: (httpClient.getImagesGif(tokenString: tokenString)) as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error!)
                
            }
            else {
                
                if data != nil {
                    
                    do {
                        
                        let dictResult:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if (dictResult["error"] as? String) != nil {
                            print("Error")
                            
                        } else
                            
                        {
                            
                            gifString = (dictResult["gif"] as? String)!
                            DispatchQueue.main.async {
                                self.imageGif = UIImage.gifImageWithURL(gifUrl: gifString)
                                if self.imageGif != nil{
                                    self.imagePopUp.image = self.imageGif!
                                }
                            }
                            UserDefaults.standard.synchronize()
                            
                        }
                        
                    } catch {
                        print("Error")
                    }
                }
                
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        })
        
        task.resume()
    }

    
    ///////////////////
    //To get images using Token
     func getImagess() {
        
        let session = URLSession.shared
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
            let httpClient = HttpClient()
            let task = session.dataTask(with: (httpClient.getImages(tokenString: tokenString)) as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                
                if (error != nil) {
                    print(error!)
                    
                }
                else {
                    
                    // Parse JSON
                    if data != nil {
                        
                        do {
                            
                            let dictResult:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            if let dictResultJSON = dictResult as? [String: AnyObject] {
                                if let imagesResultJSON = dictResultJSON["images"] as? [[String: AnyObject]] {
                                   // print(imagesResultJSON)
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
                                        self.galleryImagess.append(myImage)
                                    }
                                    
                                }
                                
                            }
                            
                        } catch {
                            print("Error")
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                  self.collectionView.reloadData()
                  self.activityIndicator.stopAnimating()
                }
            })
            
            task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func addImage(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showAddImage", sender: nil)
        
    }
    
    // Open PopUp
    @IBAction func getGifImage(_ sender: Any) {
        
//        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imagePoUpID") as! PopUpViewController
//        
//        self.addChildViewController(popOverVC)
//        popOverVC.view.frame = self.view.frame
//        self.view.addSubview(popOverVC.view)
//        popOverVC.didMove(toParentViewController: self)
        animateIn()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Gallery"
        navigationItem.backBarButtonItem = backItem
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         //return 2
        return self.galleryImagess.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCellCollectionView
        if galleryImagess[indexPath.row].smallImagePath != nil {
            cell.imageCustomCell.image = UIImage(data:NSData(contentsOf:galleryImagess[indexPath.row].smallImagePath) as! Data)
//            print("----")
//            print(galleryImagess[indexPath.row].smallImagePath)
        }
        cell.weatherLabel.text = galleryImagess[indexPath.row].weather
        cell.addressLabel.text = galleryImagess[indexPath.row].address
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 180)
    }
    

}






