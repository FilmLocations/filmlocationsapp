//
//  FilmLocation.swift
//  Film Locations
//
//  Created by Laura on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import Foundation
import SwiftyJSON

class FilmLocation {
    var actors: [String]?
    var description: String?
    var genreIds: [Int]?
    var id: Int
    var backdropImageURL: URL?
    var posterImageURL: URL?
    var company: String?
    var director: String?
    var writer: String?
    var date: String?
    var releaseYear: String
    var title: String
    var popularity: Int?
    var address: String
    var lat: Double
    var long: Double
    var placeId: String
    
    private let baseStringURL = "http://image.tmdb.org/t/p/w500"

    
    init(json: JSON) {
        actors = json["actors"].arrayValue.map{$0.stringValue}
        
        description = json["description"].stringValue
        
        genreIds = json["genres"].arrayValue.map{$0.intValue}
        
        id = json["tmdbid"].intValue
        
        let backdropImage = json["images"]["backdrop"].stringValue
        backdropImageURL = URL(string: baseStringURL + backdropImage)
        
        let posterImage = json["images"]["poster"].stringValue
        posterImageURL = URL(string: baseStringURL + posterImage)

        company = json["production"]["company"].stringValue
        director = json["production"]["director"].stringValue
        writer = json["production"]["writer"].stringValue
        
        date = json["date"].stringValue
        releaseYear = json["year"].stringValue
        
        title = json["title"].stringValue
        
        popularity = json["popularity"].intValue
        
        address = json["address"].stringValue
        lat = json["gps"]["lat"].doubleValue
        long = json["gps"]["lng"].doubleValue
        placeId = json["placeId"].stringValue
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
