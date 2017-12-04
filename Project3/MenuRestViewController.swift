//
//  MenuRestViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

let URL_REST_LOADMENU = "http://gmonna.pythonanywhere.com/rest_api/v1.0/load_menu"
let preferences = UserDefaults.standard

class MenuRestViewController: UIViewController {
    var allMenu = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters: Parameters=[
            "email_rest": preferences.object(forKey: "userEmail") as! String
        ]
        
        Alamofire.request(URL_REST_LOADMENU, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
            {
                response in
                //printing response
                print(response)
                
                
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    
                    for(_, value) in jsonData{
                        let menuItem = value as! NSDictionary
                        self.allMenu.append(menuItem)
                        print(value)
                    }
                }
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goAppetizers(_ sender: Any) {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuSectionRest") as! MenuSectionRestViewController
        mainViewController.title = "Appetizers"
        mainViewController.menuItems = [NSDictionary]()
        mainViewController.section = "appetizers"
        
        for menuItem in allMenu {
            if (menuItem.value(forKey: "section") as! String == "appetizers") {
                mainViewController.menuItems.append(menuItem)
            }
        }
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func goEntrees(_ sender: Any) {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuSectionRest") as! MenuSectionRestViewController
        mainViewController.title = "Entrees"
        mainViewController.menuItems = [NSDictionary]()
        mainViewController.section = "entrees"
        
        for menuItem in allMenu {
            if (menuItem.value(forKey: "section") as! String == "entrees") {
                mainViewController.menuItems.append(menuItem)
            }
        }
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func goDesserts(_ sender: Any) {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuSectionRest") as! MenuSectionRestViewController
        mainViewController.title = "Desserts"
        mainViewController.menuItems = [NSDictionary]()
        mainViewController.section = "desserts"
        
        for menuItem in allMenu {
            if (menuItem.value(forKey: "section") as! String == "desserts") {
                mainViewController.menuItems.append(menuItem)
            }
        }
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
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

}
