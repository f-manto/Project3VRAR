//
//  RestSettingsViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

class RestSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var addressField: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var imagePicked: UIImageView!
    
    let preferences = UserDefaults.standard
    let URL_REST_GETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/get_settings"
    let URL_REST_SETSETTINGS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/set_settings_rest"
    let URL_REST_IMAGE = "http://gmonna.pythonanywhere.com/rest_api/v1.0/upload_image"
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
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
                    self.addressField.text = jsonData.value(forKey: "address") as? String
                    self.descriptionField.text = jsonData.value(forKey: "description") as? String
                }
            }
        // Do any additional setup after loading the view.
        }
    }
    
    @IBAction func loadImageButtonTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        
        /*
         The sourceType property wants a value of the enum named        UIImagePickerControllerSourceType, which gives 3 options:
         
         UIImagePickerControllerSourceType.PhotoLibrary
         UIImagePickerControllerSourceType.Camera
         UIImagePickerControllerSourceType.SavedPhotosAlbum
         
         */
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changeSettings(_ sender: Any) {
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "address": self.addressField.text!,
            "desc": self.descriptionField.text!
        ]
        
        Alamofire.request(URL_REST_SETSETTINGS, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
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
                    }
                }
            }
        
        if (imagePicked.image != nil) {
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data"
            ]
            
            let final = preferences.object(forKey: "userEmail") as! String
            let new_url = URL_REST_IMAGE + "?email=" + final
            
            let URL_im = try! URLRequest(url: new_url, method: .post, headers: headers)
            let imageData = UIImageJPEGRepresentation(imagePicked.image!, 0.6)
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                multipartFormData.append(imageData!, withName: "image", fileName: "profile_image.jpeg", mimeType: "image/jpeg")

            }, with: URL_im, encodingCompletion: { (result) in
                
                switch result {
                    
                case .success(let upload, _, _):
                    upload.responseJSON {
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
                    
                case .failure(_):
                    let alert = UIAlertController(title: "Error", message: "Image uploading request failed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicked.contentMode = .scaleAspectFit
            imagePicked.image = pickedImage
        }
        
        
        /*
         
         Swift Dictionary named “info”.
         We have to unpack it from there with a key asking for what media information we want.
         We just want the image, so that is what we ask for.  For reference, the available options are:
         
         UIImagePickerControllerMediaType
         UIImagePickerControllerOriginalImage
         UIImagePickerControllerEditedImage
         UIImagePickerControllerCropRect
         UIImagePickerControllerMediaURL
         UIImagePickerControllerReferenceURL
         UIImagePickerControllerMediaMetadata
         
         */
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
}
