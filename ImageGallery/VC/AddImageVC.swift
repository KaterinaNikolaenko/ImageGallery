//
//  AddImageVC.swift
//  ImageGallery
//
//  Created by Katerina on 26.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit
import CoreLocation

class AddImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate  {
    
  // @IBOutlet weak var descriptionText: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var hashtagText: UITextField!
    
    @IBOutlet weak var myImageButton: UIButton!

    @IBOutlet weak var submitButton: UIButton!
    var descriptionText1:String = ""
   let tokenString:String = UserDefaults.standard.string(forKey: "token")!
    
    var hashtagText1:String = ""
    
    let picker = UIImagePickerController()
    
    let locationManager = CLLocationManager()
    
    var activityIndicator = UIActivityIndicatorView()
    
    let imagePlaceholder = UIImage(named:"placeholder")
    
    var locationLatitude:Double = 0.0
    var locationLongitude:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
        
        self.hashtagText.delegate = self
        self.descriptionText.delegate = self
        
        self.title = "Upload Image"
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        hashtagText.resignFirstResponder()
        descriptionText.resignFirstResponder()
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        locationLatitude = location.coordinate.latitude
        locationLongitude = location.coordinate.longitude
        
    }
    
    @IBAction func addImage(_ sender: Any) {
        self.submitButton.isEnabled = false
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

        descriptionText1 = self.descriptionText.text!
        hashtagText1 = self.hashtagText.text!
        if myImageButton.currentImage == imagePlaceholder {
            createAlert(title: "Error in form", message: "Please add image")
            self.submitButton.isEnabled = true
        }
        else {
            
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
            let httpClient = HttpClient()
            let userData = Image()
            userData.latitude = locationLatitude
            userData.longitude = locationLongitude
            userData.description = descriptionText1
            userData.hashtag = hashtagText1
            
            httpClient.postImage(tokenString: tokenString, image: myImageButton.currentImage!, data: userData, successCallback: {
                (response) -> Void in
                
           DispatchQueue.main.sync {
                    self.submitButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.createAlert(title: "Upload picture", message: "Your picture was successfully uploaded")
               }
                
                
            }, errorCallback: {
                (error) -> Void in
                
                // Show popup with error message
                print(error.error)
                DispatchQueue.main.async {
                    self.createAlert(title: "Upload picture", message: "Picture didn't uploaded")
                }
                
            })
        }
    }

    
}



