//
//  ViewController.swift
//  ImageGallery
//
//  Created by Katerina on 25.03.17.
//  Copyright © 2017 Katerina. All rights reserved.
//

import UIKit


class AuthorizationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    var signupMode = false
    
    var activityIndicator = UIActivityIndicatorView()
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupOrLogin: UIButton!
    @IBOutlet weak var changeSignupModeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
   
    let picker = UIImagePickerController()
    let imagePlaceholder = UIImage(named:"placeholder")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       picker.delegate = self
       photoButton.setRounded()
        
      self.navigationController?.navigationBar.tintColor = UIColor.white
      self.navigationController?.navigationBar.backgroundColor = UIColor.red

        
      emailTextField.delegate = self
      passwordTextField.delegate = self
      userNameTextField.delegate = self
        
      userNameTextField.attributedPlaceholder =
            NSAttributedString(string: "UserName", attributes: [NSForegroundColorAttributeName : UIColor.gray])
      emailTextField.attributedPlaceholder =
            NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.gray])
      passwordTextField.attributedPlaceholder =
            NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.gray])
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        signupOrLogin.setTitle("Log In", for: [])
        changeSignupModeButton.setTitle("Sign Up", for: [])
        photoButton.alpha = 0
        userNameTextField.alpha = 0
        messageLabel.text = "Don't have an account?"
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        return true
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
                
                    if photoButton.currentImage == imagePlaceholder {
                         createAlert(title: "Error in form", message: "Please add your Avatar")
                      } else {
                        signUp()
                  }

                
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
        let userData = PostLoginRequest()
        userData.email = emailTextField.text!
        userData.password = passwordTextField.text!
        
        httpClient.postLogIn2(data: userData, successCallback: {
            (response) -> Void in
            
            // Get token, go to next screen, etc.
            UserDefaults.standard.setValue(response.token, forKey: "token")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.sync {
                // self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "showListOfImages", sender: nil)
            }

            
        }, errorCallback: {
            (error) -> Void in
            
            // Show popup with error message
            print(error.message)
            DispatchQueue.main.async {
                self.createAlert(title: "Signup Error", message: "Please try again! User with this email already exists!")
            }
            
        })
        
        
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
                                self.createAlert(title: "Signup Error", message: "Please try again! User with this email already exists!")
                            }
                            
                        }
                        else if let dictResultJSON = dictResult as? [String: AnyObject] {
                             if let dictResultJSON1 = dictResultJSON["children"] as? [String: AnyObject] {
                                if let dictResultJSON2 = dictResultJSON1["email"] as? [String: AnyObject] {
                                    if (dictResultJSON2["errors"]) != nil{
                                        DispatchQueue.main.async {
                                            self.createAlert(title: "Signup Error", message: "Please try again! User with this email already exists!")
                                        }
                                    }
                                }
                            }
                        } else
                            
                        {
                           // print(dictResult)
                            token = (dictResult["token"] as? String)!
                            UserDefaults.standard.setValue(token, forKey: "token")
                            UserDefaults.standard.synchronize()

                            DispatchQueue.main.sync {
                               // self.activityIndicator.stopAnimating()
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
    


}

