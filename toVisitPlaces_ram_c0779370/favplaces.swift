//
//  favplaces.swift
//  toVisitPlaces_ram_c0779370
//
//  Created by rschakar on 6/16/20.
//  Copyright © 2020 rs_chakar. All rights reserved.
//


import Foundation
import MapKit

class favplaces{
    var placeLat: Double
    var placeLong: Double
    var placeName :String
    var city :String
    var postalCode : String
    var country : String
    
    init(placeLat:Double , placeLong: Double, placeName:String, city:String, postalCode: String, country:String) {
        self.placeLat = placeLat
        self.placeLong = placeLong
        self.placeName = placeName
        self.city = city
        self.postalCode = postalCode
        self.country = country
    }
    
    
}
