//
//  ExpandableObject.swift
//  Film Locations
//
//  Created by Laura on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import Foundation
import SwiftyJSON

class Movie {
    var actors: [String]?
    var description: String?
    var genreIds: [Int]?
    var id: Int
    var backdropImageURL: URL? //String
    var posterImageURL: URL?
    var company: String?
    var director: String?
    var writer: String?
    var date: String?
    var releaseYear: String
    var title: String
    
    //TODO NEED TO REMOVE THESE, since each of these objects is now always 1 location
    
    var locations: [Location]
    var isExpandable: Bool { return locations.count > 1 }
    var isExpanded: Bool
    var numberOfRows: Int { return locations.count }
    
    //////
    
    
    var popularity: Int?
    var location: Location?
    
    private let baseStringURL = "http://image.tmdb.org/t/p/w500"

    
    init(json: JSON) {
        self.actors = json["actors"].arrayValue.map{$0.stringValue}
        
        self.description = json["description"].stringValue
        
        self.genreIds = json["genres"].arrayValue.map{$0.intValue}
        
        self.id = json["tmdbid"].intValue
        
        let backdropImage = json["images"]["backdrop"].stringValue
        self.backdropImageURL = URL(string: baseStringURL + backdropImage)
        
        let posterImage = json["images"]["poster"].stringValue
        self.posterImageURL = URL(string: baseStringURL + posterImage)

        self.company = json["production"]["company"].stringValue
        self.director = json["production"]["director"].stringValue
        self.writer = json["production"]["writer"].stringValue
        
        self.date = json["date"].stringValue
        self.releaseYear = json["year"].stringValue
        
        self.title = json["title"].stringValue
        
        self.popularity = json["popularity"].intValue
        
        let address = json["address"].stringValue
        let lat = json["gps"]["lat"].doubleValue
        let long = json["gps"]["lng"].doubleValue
        let placeId = json["placeId"].stringValue
        
        self.location = Location(placeId: placeId, address: address, lat: lat, long: long)
        
        self.locations = [self.location!]
        self.isExpanded = false
    }
    
    private var formatConversion = { (stringDate: String?) -> String? in
        var returnDate: String?
        
        if let stringDate = stringDate {
            var formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            if let date = formatter.date(from: stringDate) {
                formatter.dateFormat = "MMM dd, YYYY"
                returnDate = formatter.string(from: date)
            }
        }
        return returnDate
    }
}
