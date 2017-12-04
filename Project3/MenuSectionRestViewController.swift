//
//  MenuSectionRestViewController.swift
//  Project3
//
//  Created by Gianclè Monna on 12/3/17.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import UIKit
import Alamofire

class MenuSectionRestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var itemsTable: UITableView!
    
    var menuItems = [NSDictionary]()
    var section: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemsTable.delegate = self
        self.itemsTable.dataSource = self
    }
    
    @IBAction func addMenuItem(_ sender: Any) {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddMenuItem") as! AddMenuItemViewController
        mainViewController.section = section
        
        self.navigationController?.pushViewController(mainViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = menuItems[indexPath.row].value(forKey: "name") as! String
        
        return cell!
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Segue to the second view controller
        self.performSegue(withIdentifier: "modelSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! UploadModelViewController
        let indexPath = self.itemsTable.indexPathForSelectedRow
        // set a variable in the second view controller with the data to pass
        secondViewController.menuItem = menuItems[indexPath!.row] as! NSDictionary
        secondViewController.title = (menuItems[indexPath!.row] as! NSDictionary).value(forKey: "name") as! String
    }
}
