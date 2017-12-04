//
//  MaInViewController.swift
//  ARKitBasics
//
//  Created by Francesco Mantovani on 01/12/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

let URL_USER_LOGOUT = "http://gmonna.pythonanywhere.com/rest_api/v1.0/logout"

class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    let locationManager = CLLocationManager()
    let companyName = ["apple", "amazon"]
    let share = [1, 2]
    
    var restaurants = [Restaurant]()
    
    let URL_LOAD_RESTAURANTS = "http://gmonna.pythonanywhere.com/rest_api/v1.0/load_restaurants"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
//        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        loadRestaurants()
        
        let preferences = UserDefaults.standard
        self.nameLabel.text = preferences.object(forKey: "userName") as? String
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            //showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
            print("error")
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = restaurants[indexPath.row].name
        cell?.detailTextLabel?.text = restaurants[indexPath.row].address
        
        return cell!
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Change the selected background view of the cell.
        tableView.deselectRow(at: indexPath, animated: true)
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

    
    //CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
//        let latestLocation: CLLocation = locations[locations.count - 1]
//
//        latitude.text = String(format: "%.4f",
//                               latestLocation.coordinate.latitude)
//        longitude.text = String(format: "%.4f",
//                                latestLocation.coordinate.longitude)
//        horizontalAccuracy.text = String(format: "%.4f",
//                                         latestLocation.horizontalAccuracy)
//        altitude.text = String(format: "%.4f",
//                               latestLocation.altitude)
//        verticalAccuracy.text = String(format: "%.4f",
//                                       latestLocation.verticalAccuracy)
        
//        if startLocation == nil {
//            startLocation = latestLocation
//        }
        
//        let distanceBetween: CLLocationDistance =
//            latestLocation.distance(from: startLocation)
//
//        distance.text = String(format: "%.2f", distanceBetween)
        print("here")
        print(locations[locations.count - 1].coordinate.latitude)
        
        let title = "Circle"
        let coordinate = CLLocationCoordinate2DMake(41.8761, -87.6525)
        let regionRadius = 300.0
        
        // 3. setup region
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                     longitude: coordinate.longitude), radius: regionRadius, identifier: title)
        print(region.contains(locations[locations.count - 1].coordinate))
        
    }
    
    func loadRestaurants(){
        Alamofire.request(URL_LOAD_RESTAURANTS, method: .post).responseJSON
            {
                response in
                //printing response
                print(response)
                
                
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    
                    for(key, value) in jsonData{
                        let restDict = value as! NSDictionary
                        let restaurant = Restaurant(toParse: restDict)
                        self.restaurants.append(restaurant)
                        
                        
                    }
                    
                    
                    print("here")
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    
                }
                

        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        let preferences = UserDefaults.standard
        let userEmail = preferences.object(forKey: "userEmail") as! String
        
        let parameters: Parameters=[
            "email": userEmail,
            ]
        
        Alamofire.request(URL_USER_LOGOUT, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON
            {
                response in
                //printing response
                print("Response:")
                print(response)
                
                //getting the json value from the server
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    
                    //if there is no error
                    let error = jsonData.value(forKey: "error") as! String
                    if (error == "yes") {
                        print(jsonData.value(forKey: "message") as! String)
                    }
                    else{
                        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "LogIn") as! UIViewController
                        self.navigationController?.pushViewController(mainViewController, animated: true)
                        self.dismiss(animated: false, completion: nil)
                    }
                }
        }
       
    }
}

