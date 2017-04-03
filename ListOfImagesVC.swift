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
    var galleryImagess = [Image]()
    var imageGif : UIImage?
    var effect:UIVisualEffect!
    var httpClient:HttpClient = HttpClient()
    
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
        self.activityIndicator.stopAnimating()
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
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        self.httpClient.getImagesGif(tokenString: tokenString, successCallback: {
            (response) -> Void in
    
            DispatchQueue.main.sync {
                self.activityIndicator.stopAnimating()
                self.imagePopUp.image = response
            }
            
        }, errorCallback: {
            (error) -> Void in
            
            // Show popup with error message
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.createAlert(title: "Error", message: "")
            }
            
        })
       // DispatchQueue.main.sync {
          activityIndicator.stopAnimating()
       // }

    }

    
    //To get images using Token
     func getImagess() {
               
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        self.httpClient.getImages(tokenString: tokenString, successCallback: {
            (response) -> Void in
           
            DispatchQueue.main.sync {
                self.galleryImagess = response
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
                
            }
            
        }, errorCallback: {
            (error) -> Void in
            
            // Show popup with error message
            print(error.error)
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.createAlert(title: "Error", message: "")
            }
            
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func addImage(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showAddImage", sender: nil)
        
    }
    
    // Open PopUp
    @IBAction func getGifImage(_ sender: Any) {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCellCollectionView
        let imageData = galleryImagess[indexPath.row]
        if galleryImagess[indexPath.row].smallImagePath != nil {
            self.httpClient.downloadImage(imageUrl: imageData.smallImagePath, successCallback: { (image) in
                DispatchQueue.main.sync {
                    cell.imageCustomCell.image = image
                }
            })
        }
        cell.weatherLabel.text = imageData.weather
        cell.addressLabel.text = imageData.address
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        var tileSize = CGFloat(180.0)
        if(screenSize.width > screenSize.height) {
            tileSize = screenSize.width / 4.0
        }else{
            tileSize = screenSize.width / 2.0
        }

        
        return CGSize(width: tileSize, height: tileSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

}






