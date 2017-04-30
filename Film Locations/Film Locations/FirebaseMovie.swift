//
//  Movie.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import Foundation

class FirebaseMovie {
    var title: String
    var releaseYear: String
    var posterImageURL: URL
    var locationImageURL: URL
    var address: String
    var distance: Float
    
    init(title: String, releaseYear: String, posterImageURL: URL, locationImageURL: URL, address: String, distance: Float)
    {
        self.title = title
        self.releaseYear = releaseYear
        self.posterImageURL = posterImageURL
        self.locationImageURL = locationImageURL
        self.address = address
        self.distance = distance
    }
}
