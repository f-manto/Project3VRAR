//
//  LogInViewController.swift
//  ARKitBasics
//
//  Created by Francesco Mantovani on 30/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import Alamofire

class LogInViewController: UIViewController {

    let URL_USER_LOGIN = "http://gmonna.pythonanywhere.com/rest_api/v1.0/login"
    let URL_USER_LOGGEDIN = "http://gmonna.pythonanywhere.com/rest_api/v1.0/already_logged_in"


    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var userType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let preferences = UserDefaults.standard
        if(preferences.object(forKey: "userEmail") != nil)
        {
//            LoginDone()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func doLogin(_ sender: Any) {
        var userT: String!
        
        if (userType.selectedSegmentIndex==1){
            userT = "restaurant"
        }else{
            userT = "user"
        }
        
        let parameters: Parameters=[
            "email": emailField.text!,
            "type": userT!,
            "password": passwordField.text!
        ]
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    
                    //if there is no error
                    let error = jsonData.value(forKey: "error") as! String
                    if (error == "yes") {
                        let alert = UIAlertController(title: "Error", message: jsonData.object(forKey: "message") as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        //getting the user from response
//                        let user = jsonData.value(forKey: "user") as! NSDictionary
                        
                        //getting user values
                        let userName = jsonData.value(forKey: "name") as! String
                        print(userName)
                        
                        let userEmail = self.emailField.text
                        let preferences = UserDefaults.standard
                        preferences.set(userEmail, forKey: "userEmail")
                        preferences.set(userName, forKey: "userName")
                        preferences.set(userT, forKey: "userType")
                        
                        //saving user values to defaults
//                      self.defaultValues.set(userName, forKey: "name")
                        
//                      switching the screen
                        if (userT == "user") {
                            let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! UIViewController
                            self.navigationController?.pushViewController(mainViewController, animated: true)
                            self.dismiss(animated: false, completion: nil)
                        } else {
                            let mainRestViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainRest") as! UIViewController
                            self.navigationController?.pushViewController(mainRestViewController, animated: true)
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                }
        }
    }
    
    func LoginDone()
    {
        let preferences = UserDefaults.standard
        let userEmail = preferences.object(forKey: "userEmail") as! String
        
        let parameters: Parameters=[
            "email": userEmail,
        ]

        Alamofire.request(URL_USER_LOGGEDIN, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
            {
                response in
                //printing response
                print(response)
                
                //getting the json value from the server
//                if let result = response.result.value {
//                    let jsonData = result as! NSDictionary
//
//                    //if there is no error
//                    let error = jsonData.value(forKey: "error") as! String
//                    if (error == "yes") {
//                        print(jsonData.value(forKey: "message") as! String)
//                        //                        self.labelMessage.text = jsonData.value(forKey: "message") as! String
//                    } else {
//
//                        //getting the user from response
//                        let user = jsonData.value(forKey: "user") as! NSDictionary
//
//                        //getting user values
//                        let userName = jsonData.value(forKey: "name") as! String
//                        print(userName)
//
//                        let userEmail = user.value(forKey: "email") as! String
//                        let preferences = UserDefaults.standard
//                        preferences.set(userEmail, forKey: "userEmail")
//
//                        //saving user values to defaults
//                        //                        self.defaultValues.set(userName, forKey: "name")
//
//                        //switching the screen
//                        //                        let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewcontroller") as! ProfileViewController
//                        //                        self.navigationController?.pushViewController(profileViewController, animated: true)
//
//                        //                        self.dismiss(animated: false, completion: nil)
//                    }
//                }
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func next(_ sender: Any) {
                                let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! UIViewController
                                self.navigationController?.pushViewController(mainViewController, animated: true)
                                self.dismiss(animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
