//
//  PDFMenuViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

class PDFMenuViewController: UIViewController {
    
    let URL_REST_MENUPDF = "http://gmonna.pythonanywhere.com/rest_api/v1.0/download_menu"
    let URL_REST_DELETE_MENUPDF = "http://gmonna.pythonanywhere.com/rest_api/v1.0/delete_menu"
    
    let preferences = UserDefaults.standard
    var pdfData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("mymenu.pdf")
            return (documentsURL, [.removePreviousFile])
        }
        
        let parameters: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
            "name": preferences.object(forKey: "userName") as! String
        ]
        
        Alamofire.download(URL_REST_MENUPDF, method: .post, parameters: parameters, encoding: JSONEncoding.default, to: destination)
            .validate { request, response, temporaryURL, destinationURL in
                // Custom evaluation closure now includes file URLs (allows you to parse out error messages if necessary)
                return .success
            }
            .response {
                response in
                print(response.destinationURL!)
                let dataPDF = try? Data(contentsOf: response.destinationURL!)
                self.pdfData = dataPDF!
                
                let webView = WKWebView(frame: CGRect(x:20,y:20,width:self.view.frame.size.width-40, height:self.view.frame.size.height-40))
                webView.load(dataPDF!, mimeType: "application/pdf", characterEncodingName:"", baseURL: response.destinationURL!.deletingLastPathComponent())
                self.view.addSubview(webView)
        }
        
        let parameters_two: Parameters=[
            "email": preferences.object(forKey: "userEmail") as! String,
        ]
        //making a post request
        Alamofire.request(URL_REST_DELETE_MENUPDF, method: .post, parameters: parameters_two, encoding: JSONEncoding.default).responseJSON
            {
                response in
                //printing response
                print(response)
            }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionsToDo(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [self.pdfData!], applicationActivities:nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
