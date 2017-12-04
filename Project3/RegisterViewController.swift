//
//  RegisterViewController.swift
//  ARKitBasics
//
//  Created by Francesco Mantovani on 30/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {

    let URL_USER_SIGNUP = "http://gmonna.pythonanywhere.com/rest_api/v1.0/signup"
    
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordFieldC: UITextField!
    @IBOutlet weak var userType: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func doSignUp(_ sender: Any) {
        var userT: String!
        
        if (userType.selectedSegmentIndex==1){
            userT = "restaurant"
        }else{
            userT = "user"
        }
        
        if (((passwordField.text)?.count)! < 8){
            let alert = UIAlertController(title: "Error", message: "Password should be at least 8 characters.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
   
        if (passwordField.text != passwordFieldC.text) {
            
            let alert = UIAlertController(title: "Error", message: "Password and confirmation are different.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let parameters: Parameters=[
            "email": emailField.text!,
            "name": fullNameField.text!,
            "type": userT!,
            "password": passwordField.text!
        ]
        
        //making a post request
        Alamofire.request(URL_USER_SIGNUP, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
            {
                response in
                //printing response
                print("Response:")
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    
                    //if there is no error
                    let error = jsonData.value(forKey: "error") as! String
                    if (error == "yes") {
                        print(jsonData.value(forKey: "message") as! String)
                        let errmsg = jsonData.value(forKey: "message") as! String
                        if (errmsg == "User already exists"){
                            let alert = UIAlertController(title: "Error", message: "Email address already in use.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        let userName = self.fullNameField.text!
                        print(userName)
                        
                        let userEmail = self.emailField.text
                        let preferences = UserDefaults.standard
                        preferences.set(userEmail, forKey: "userEmail")
                        preferences.set(userName, forKey: "userName")
                        
        
                        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "Main") as! UIViewController
                        self.navigationController?.pushViewController(mainViewController, animated: true)
                        
                        self.dismiss(animated: false, completion: nil)
                    }
                }
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
