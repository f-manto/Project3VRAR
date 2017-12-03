//
//  RestSettingsViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

class RestSettingsViewController: UIViewController {
    @IBOutlet weak var addressField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    
    let preferences = UserDefaults.standard
    let URL_USER_GETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/get_settings"
    let URL_USER_SETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/set_settings_rest"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "type": preferences.object(forKey: "userType") as! String
        ]
        
        Alamofire.request(URL_USER_GETSETTINGS, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            print(response)
            
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                
                let error = jsonData.value(forKey: "error") as! String
                if (error == "no") {
                    self.addressField.text = jsonData.value(forKey: "address") as? String
                    self.descriptionField.text = jsonData.value(forKey: "description") as? String
                }
            }
        // Do any additional setup after loading the view.
        }
    }
    
    @IBAction func changeSettings(_ sender: Any) {
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "address": self.addressField.text!,
            "desc": self.descriptionField.text!
        ]
        
        Alamofire.request(URL_USER_SETSETTINGS, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
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
                        let alert = UIAlertController(title: "Settings updated", message: jsonData.object(forKey: "message") as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
