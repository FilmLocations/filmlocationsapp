//
//  Movie.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import Foundation
import SwiftyJSON

class FirebaseMovie {
    
    private let posterStringBaseURL = "http://image.tmdb.org/t/p/w185/"
    
    var title: String {
        return json["title"].stringValue
    }
    
    var releaseYear: String {
        return json["release"]["year"].stringValue
    }
    var posterImageURL: URL? {
        let stringURL = posterStringBaseURL + json["images"]["poster"].stringValue
        return URL(string: stringURL)
    }
    
    var address: String {
        return json["location"]["address"].stringValue
    }
    
//    init(title: String, releaseYear: String, posterImageURL: URL, locationImageURL: URL, address: String, distance: Float)
//    {
//        self.title = title
//        self.releaseYear = releaseYear
//        self.posterImageURL = posterImageURL
//        self.locationImageURL = locationImageURL
//        self.address = address
//        self.distance = distance
//    }

    private let json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    
    
}
