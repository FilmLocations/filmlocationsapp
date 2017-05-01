//
//  Location.swift
//  Film Locations
//
//  Created by Laura on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import Foundation

class Location {
    var address: String
    var placeId: String
    var lat: Double
    var long: Double

    init(placeId: String, address: String, lat: Double, long: Double) {
        self.placeId = placeId
        self.address = address
        self.lat = lat
        self.long = long
    }
}
