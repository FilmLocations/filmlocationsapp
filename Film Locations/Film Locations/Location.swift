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
    var locationImageURL: URL
    
    init(address: String, locationImageURL: URL) {
        self.address = address
        self.locationImageURL = locationImageURL
    }
}
