//
//  UploadModelViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

import Photos
import BSImagePicker

import UserNotifications

let URL_UPLOAD_MODEL = "http://gmonna.pythonanywhere.com/rest_api/v1.0/load_images_3d"

extension UIViewController: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}

class UploadModelViewController: UIViewController {
    var menuItem: NSDictionary!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var imagesView: UIImageView!
    
    @IBOutlet weak var activityRotel: UIActivityIndicatorView!
    @IBOutlet weak var labelRotel: UILabel!
    
    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    
    var strLabel = UILabel()
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var loadingView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descField.text = menuItem.value(forKey: "desc") as! String
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().delegate = self
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.activityRotel.stopAnimating()
        self.labelRotel.text = ""
    }

    @IBAction func addImages(_ sender: Any) {
        let vc = BSImagePickerViewController()
        
        self.bs_presentImagePickerController(vc, animated: true, select: { (asset: PHAsset) -> Void in
            
        }, deselect: { (asset: PHAsset) -> Void in
            
        }, cancel: { (assets: [PHAsset]) -> Void in
            
        }, finish: { (assets: [PHAsset]) -> Void in
            for i in 0..<assets.count {
                self.selectedAssets.append(assets[i])
            }
            self.convertAssetToImages()
        }, completion: nil)
    }
    
    func convertAssetToImages() -> Void {
        if selectedAssets.count != 0 {
            for i in 0..<selectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                    
                })
                
                let data = UIImageJPEGRepresentation(thumbnail, 0.7)
                let newImage = UIImage(data: data!)
                
                self.photoArray.append(newImage! as UIImage)
            }
            
            self.imagesView.animationImages = self.photoArray
            self.imagesView.animationDuration = 3.0
            self.imagesView.startAnimating()
        }
    }
    
    @IBAction func createModel(_ sender: Any) {
        if (photoArray.count >= 3) {
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data"
            ]
            
            let final = preferences.object(forKey: "userEmail") as! String
            let id_dish = menuItem.value(forKey: "id") as! Int
            let new_url = URL_UPLOAD_MODEL + "?email=" + final + "&id_dish=" + String(id_dish)
            
            let URL_im = try! URLRequest(url: new_url, method: .post, headers: headers)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activityRotel.startAnimating()
            self.labelRotel.text = "Hold on, you will receive a notification when the upload is done"
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 1500
            
            let alamofireManager = Alamofire.SessionManager(configuration: configuration)
            alamofireManager.upload(multipartFormData: { (multipartFormData) in
                
                for (_, image) in self.photoArray.enumerated() {
                    if let imageData = UIImageJPEGRepresentation(image, 0.6) {
                        multipartFormData.append(imageData, withName: "images[]", fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "image/jpeg")
                    }
                }
                
            }, with: URL_im, encodingCompletion: { (result) in
                switch result {
                    
                case .success(let upload, _, _):
                    upload.responseJSON {
                        response in
                        //printing response
                        print(response)
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activityRotel.stopAnimating()
                        self.labelRotel.text = ""
                        
                        // Request Notification Settings
                        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
                            switch notificationSettings.authorizationStatus {
                            case .notDetermined:
                                self.requestAuthorization(completionHandler: { (success) in
                                    guard success else { return }
                                    
                                    // Schedule Local Notification
                                    self.scheduleLocalNotification()
                                })
                            case .authorized:
                                // Schedule Local Notification
                                self.scheduleLocalNotification()
                            case .denied:
                                print("Application Not Allowed to Display Notifications")
                            }
                        }
                        
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
        } else {
            let alert = UIAlertController(title: "Error", message: "You have to upload at least 3 photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "ARMenus"
        notificationContent.subtitle = "Model creation started"
        notificationContent.body = "Hold on, your model will be ready in a while! You are going to receive an email on your account."
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "armenus_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
}
