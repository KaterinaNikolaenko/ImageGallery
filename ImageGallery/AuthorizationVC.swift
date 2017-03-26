//
//  ViewController.swift
//  ImageGallery
//
//  Created by Katerina on 25.03.17.
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

class AuthorizationVC: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var signupMode = true
    var activityIndicator = UIActivityIndicatorView()
    
    let urlLogin = NSURL(string: "http://api.doitserver.in.ua/login")!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupOrLogin: UIButton!
    @IBOutlet weak var changeSignupModeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       picker.delegate = self
       photoButton.setRounded()
        
      self.navigationController?.navigationBar.tintColor = UIColor.white
      self.navigationController?.navigationBar.backgroundColor = UIColor.red

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func selectPhoto(_ sender: Any) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        present(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
        
    {
        
        photoButton.setImage(info[UIImagePickerControllerOriginalImage] as? UIImage, for: UIControlState.normal)
        
       self.dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func changeSignupMode(_ sender: Any) {
        if signupMode {
            
            // Change to login mode
            
            signupOrLogin.setTitle("Log In", for: [])
            
            changeSignupModeButton.setTitle("Sign Up", for: [])
            
            photoButton.alpha = 0
            
            userNameTextField.alpha = 0
            
            messageLabel.text = "Don't have an account?"
            
            signupMode = false
            
        } else {
            
            // Change to signup mode
            
            signupOrLogin.setTitle("Sign Up", for: [])
            
            changeSignupModeButton.setTitle("Log In", for: [])
            
            messageLabel.text = "Already have an account?"
            
            signupMode = true
            
            photoButton.alpha = 1
            
            userNameTextField.alpha = 1
            
        }
    }
    
    
    @IBAction func signupOrLogin(_ sender: Any) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            createAlert(title: "Error in form", message: "Please enter an email and password")
            
        } else {
            
            if signupMode {
                // Sign Up
                signUp()
                
            } else {
                // Login mode
                self.signIn()
            }
        }
    }
    
    func signUp(){
        
        var token = ""
        
        let session = URLSession.shared
        
        let httpClient = HttpClient()

        let task = session.dataTask(with: (httpClient.postUser(email: emailTextField.text!, password: passwordTextField.text!, username: userNameTextField.text!, image: photoButton.currentImage!)) as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            
            if (error != nil) {
                print(error!)
                
            }
            else {
                
                if data != nil {
                    
                    do {
                        
                        let dictResult:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if (dictResult["error"] as? String) != nil {
                            
                            print(dictResult)
                            DispatchQueue.main.async {
                                self.createAlert(title: "Signup Error", message: "Please try again!")
                            }
                            
                        } else
                            
                        {
                            print(dictResult)
                            token = (dictResult["token"] as? String)!
                            UserDefaults.standard.setValue(token, forKey: "token")
                            UserDefaults.standard.synchronize()

                            DispatchQueue.main.sync {
                                self.performSegue(withIdentifier: "showListOfImages", sender: nil)
                            }
                            
                        }
                        
                    } catch {
                        print("Error")
                    }
                }
                
            }
            
        })
        
        task.resume()
        
    }
    
    
    func signIn(){

        var token = ""
        
        let session = URLSession.shared
        
        let httpClient = HttpClient()
        
            let task = session.dataTask(with: (httpClient.postLogIn(email: emailTextField.text!, password: passwordTextField.text!)) as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                
                if (error != nil) {
                    print(error!)
                    
                }
                else {
                    
                    if data != nil {
                        
                        do {
                            
                            let dictResult:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                           
                            if (dictResult["error"] as? String) != nil {
        
                                DispatchQueue.main.async {
                                    self.createAlert(title: "Login Error", message: "Please try again!")
                                }
                                
                            } else
                                
                            {
                                token = (dictResult["token"] as? String)!
                                UserDefaults.standard.setValue(token, forKey: "token")
                                UserDefaults.standard.synchronize()
                                
                                DispatchQueue.main.sync {
                                 self.performSegue(withIdentifier: "showListOfImages", sender: nil)
                              }
                                
                            }
                            
                        } catch {
                             print("Error")
                        }
                    }
                    
                }
                
            })
            
            // Start the task on a background thread
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

