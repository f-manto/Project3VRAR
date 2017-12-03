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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let preferences = UserDefaults.standard
        self.restName.text = preferences.object(forKey: "userName") as? String
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
