//
//  LostPasswordViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/2/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

class LostPasswordViewController: UIViewController {

    let URL_USER_LOSTPASS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/lost_password"
    
    @IBOutlet weak var switchUser: UISegmentedControl!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func sendPassword(_ sender: Any) {
        var userT: String!
        
        if (switchUser.selectedSegmentIndex==1){
            userT = "restaurant"
        }else{
            userT = "user"
        }
        
        let parameters: Parameters=[
            "email": emailField.text!,
            "type": userT!
        ]
        
        //making a post request
        Alamofire.request(URL_USER_LOSTPASS, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
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
                        self.messageLabel.textColor = UIColor.red
                        self.messageLabel.text = jsonData.value(forKey: "message") as? String
                    } else {
                        self.messageLabel.textColor = UIColor.green
                        self.messageLabel.text = jsonData.value(forKey: "message") as? String
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
