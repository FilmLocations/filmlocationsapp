//
//  LocationImage.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/7/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import Foundation

class LocationImage {
    var imageURL: String
    var description: String
    var userId: String
    var timestamp: String
    
    init(imageURL: String, description: String, userId: String, timestamp: String) {
        self.imageURL = imageURL
        self.description = description
        self.userId = userId
        self.timestamp = timestamp
    }
}
