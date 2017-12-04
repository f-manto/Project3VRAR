//
//  AddMenuItemViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

let URL_REST_ADDITEM = "http://gmonna.pythonanywhere.com/rest_api/v1.0/add_menu_item"

class AddMenuItemViewController: UIViewController {
    var section: String!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var caloriesField: UITextField!
    @IBOutlet weak var proteinsField: UITextField!
    @IBOutlet weak var fatsField: UITextField!
    @IBOutlet weak var carbsField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addMenuItem(_ sender: Any) {
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "name": self.nameField.text!,
            "description": self.descriptionField.text!,
            "calories": self.caloriesField.text!,
            "proteins": self.proteinsField.text!,
            "fats": self.fatsField.text!,
            "carbs": self.carbsField.text!,
            "section": section!
        ]
        
        Alamofire.request(URL_REST_ADDITEM, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
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
                        let alert = UIAlertController(title: "Success", message: jsonData.object(forKey: "message") as? String, preferredStyle: .alert)
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
