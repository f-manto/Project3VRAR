//
//  UserSettingsViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/2/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

class UserSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let URL_USER_GETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/get_settings"
    let URL_USER_SETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/set_settings_user"
    let preferences = UserDefaults.standard
    
    @IBOutlet weak var sexIndicator: UISegmentedControl!
    @IBOutlet weak var dateOfBirth: UIDatePicker!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var activityLevelPicker: UIPickerView!
    @IBOutlet weak var warningLabel: UILabel!
    
    let pickerData = ["Very low", "Low", "Medium", "High", "Very high"]
    var pickerValue: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityLevelPicker.delegate = self
        activityLevelPicker.dataSource = self
        
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
                    self.heightField.text = jsonData.value(forKey: "height") as? String
                    self.weightField.text = jsonData.value(forKey: "weight") as? String
                    
                    let sex = jsonData.value(forKey: "sex") as? String
                    if (sex == "male") {
                        self.sexIndicator.selectedSegmentIndex = 1
                    } else {
                        self.sexIndicator.selectedSegmentIndex = 2
                    }
                    
                    let actLevel = jsonData.value(forKey: "act_level") as? String
                    if (actLevel == "low") {
                        self.activityLevelPicker.selectRow(0, inComponent: 0, animated: false)
                    } else if (actLevel == "slight") {
                        self.activityLevelPicker.selectRow(1, inComponent: 0, animated: false)
                    } else if (actLevel == "medium") {
                        self.activityLevelPicker.selectRow(2, inComponent: 0, animated: false)
                    } else if (actLevel == "very") {
                        self.activityLevelPicker.selectRow(3, inComponent: 0, animated: false)
                    } else if (actLevel == "high") {
                        self.activityLevelPicker.selectRow(4, inComponent: 0, animated: false)
                    }
                    
                    let dateFormatter = DateFormatter()
                    let birthDate = jsonData.value(forKey: "dob") as! String
                    dateFormatter.dateFormat =  "MM/dd/yyyy"
                    let date = dateFormatter.date(from: birthDate)
                    self.dateOfBirth.date = date!
                }
            }
        }
    }
    
    @IBAction func changeSettings(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let strDate = dateFormatter.string(from:self.dateOfBirth.date)
        
        var sex: String!
        if (sexIndicator.selectedSegmentIndex == 0) {
            sex = "male"
        } else {
            sex = "female"
        }
        
        let selectedValue = pickerData[activityLevelPicker.selectedRow(inComponent: 0)]
        if (selectedValue == "Very Low") {
            self.pickerValue = "low"
        } else if (selectedValue == "Low") {
            self.pickerValue = "slight"
        } else if (selectedValue == "Medium") {
            self.pickerValue = "medium"
        } else if (selectedValue == "High") {
            self.pickerValue = "very"
        } else {
            self.pickerValue = "high"
        }
        
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "sex": sex,
            "height": self.heightField.text!,
            "weight": self.weightField.text!,
            "dob": strDate,
            "act_level": self.pickerValue!
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

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    private func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) {
        if (row == 0) {
            self.pickerValue = "low"
        } else if (row == 1) {
            self.pickerValue = "slight"
        } else if (row == 2) {
            self.pickerValue = "medium"
        } else if (row == 3) {
            self.pickerValue = "very"
        } else {
            self.pickerValue = "high"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
