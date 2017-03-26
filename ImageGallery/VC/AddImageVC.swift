//
//  AddImageVC.swift
//  ImageGallery
//
//  Created by Katerina on 26.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit
import CoreLocation

class AddImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var descriptionText: UITextField!
    
    @IBOutlet weak var weatherText: UITextField!
    
    @IBOutlet weak var myImageButton: UIButton!

    var descriptionText1:String = ""
    
    let picker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    
    var locationLatitude:String = "0.0"
    var locationLongitude:String = "0.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        locationLatitude = String(location.coordinate.latitude)
        locationLongitude = String(location.coordinate.longitude)
        
    }
    
    @IBAction func addImage(_ sender: Any) {
        
        myImageUploadRequest()
        
    }
    
    
    @IBAction func selectPhotoButton(_ sender: Any) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        present(myPickerController, animated: true, completion: nil)
        
    }
    
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
        
    {
        
        myImageButton.setImage(info[UIImagePickerControllerOriginalImage] as? UIImage, for: UIControlState.normal)
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func myImageUploadRequest()
    {
        
        
        let session = URLSession.shared
        let tokenString:String = UserDefaults.standard.string(forKey: "token")!
        
        
         descriptionText1 = self.descriptionText.text!
         let httpClient = HttpClient()
        
         let task = session.dataTask(with: (httpClient.postImage(latitude: locationLatitude, longitude: locationLongitude, description: descriptionText1, tokenString: tokenString, image: myImageButton.currentImage!)) as URLRequest, completionHandler: { (data, response, error) -> Void in
        
            if error != nil {
                print("error=\(error)")
                return
            }

          //  print("******* response = \(response)")

        
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                print(json!)
                
                self.createAlert(title: "Upload picture", message: "Your picture was successfully uploaded")
                
                
            }catch
            {
                print(error)
            }
            
        })
        
        task.resume()
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    

    
}



