//
//  ListOfImagesVC.swift
//  ImageGallery
//
//  Created by Katerina on 25.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit

class ListOfImagesVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let urlGetImages = NSURL(string: "http://api.doitserver.in.ua/all")!
    var tokenString:String = UserDefaults.standard.string(forKey: "token")!
    var galleryImagess = [Image()]
    var imageGif : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CustomCellCollectionView", bundle: nil), forCellWithReuseIdentifier: "MyCustomCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getImagess()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.red

    }
    
     func getImagess() {
        
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: urlGetImages as URL)
        
        do {
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "GET"
            
            request.addValue(tokenString, forHTTPHeaderField: "token")
            
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
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
                }
            })
            
            task.resume()
            
        } catch {
            print("Error")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func addImage(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showAddImage", sender: nil)
        
    }
    
    
    @IBAction func getGifImage(_ sender: Any) {
        
        getGifImages()
        let gifString:String = UserDefaults.standard.string(forKey: "gif")!
        imageGif = UIImage(data:NSData(contentsOf:URL(string: gifString)!) as! Data)
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imagePoUpID") as! PopUpViewController
        popOverVC.imageGif = imageGif
        
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)

    }
    
    func getGifImages(){
        
        var gifString = ""
        
        let session = URLSession.shared
        
        let httpClient1 = HttpClient()
        
        let task = session.dataTask(with: (httpClient1.getImages(tokenString: tokenString)) as URLRequest, completionHandler: { (data, response, error) -> Void in
            
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
                            UserDefaults.standard.setValue(gifString, forKey: "gif")
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

    
    


}

//MARK: Collection view delegate and datasourse
extension ListOfImagesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.galleryImagess.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MyCustomCell", for: indexPath) as! CustomCellCollectionView
        if galleryImagess[indexPath.row].smallImagePath != nil {
            cell.imageCustomCell.image = UIImage(data:NSData(contentsOf:galleryImagess[indexPath.row].smallImagePath) as! Data)
        }
        cell.weatherLabel.text = galleryImagess[indexPath.row].weather
        cell.addressLabel.text = galleryImagess[indexPath.row].address
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}






