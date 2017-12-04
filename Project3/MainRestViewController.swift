//
//  MainRestViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/2/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

class MainRestViewController: UIViewController {
    @IBOutlet weak var restName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionField: UITextView!
    
    let URL_REST_GETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/get_settings"
    let URL_REST_GETIMAGE = "http://gmonna.pythonanywhere.com/rest_api/v1.0/download_profile_image"
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let preferences = UserDefaults.standard
        self.restName.text = preferences.object(forKey: "userName") as? String
        // Do any additional setup after loading the view.
        
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "type": preferences.object(forKey: "userType") as! String
        ]
        
        Alamofire.request(URL_REST_GETSETTINGS, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
            response in
            print(response)
            
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                
                let error = jsonData.value(forKey: "error") as! String
                if (error == "no") {
                    self.descriptionField.text = jsonData.value(forKey: "description") as? String
                }
            }
            // Do any additional setup after loading the view.
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("profile_image.jpeg")
            return (documentsURL, [.removePreviousFile])
        }
        
        //        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        //            return (fileURL, [.createIntermediateDirectories, .removePreviousFile])
        //        }
        
        let parameters_two: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String
        ]
        
        Alamofire.download(URL_REST_GETIMAGE, method: .post, parameters: parameters_two, encoding: JSONEncoding.default, to: destination)
            .validate { request, response, temporaryURL, destinationURL in
                // Custom evaluation closure now includes file URLs (allows you to parse out error messages if necessary)
                return .success
            }
            .response {
                response in
                print(response.destinationURL!)
                let dataIm = try? Data(contentsOf: response.destinationURL!)
                self.profileImage.image = UIImage(data: dataIm!)!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
