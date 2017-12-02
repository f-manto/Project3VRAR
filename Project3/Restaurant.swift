//
//  Restaurant.swift
//  Project3
//
//  Created by Francesco Mantovani on 01/12/2017.
//  Copyright © 2017 Francesco Mantovani. All rights reserved.
//

import Foundation
import Alamofire

class Restaurant{
    var address :String
    var image: String
    var name: String
    var latitude: Double
    var longitude: Double
    
    
    init(toParse restaurant: NSDictionary ){
        address = restaurant.value(forKey: "address") as! String
        image = "image"
//            restaurant.value(forKey: "image") as! String
        name = restaurant.value(forKey: "name") as! String
        latitude = 0
        longitude = 0
        
    }
}
