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
    var releaseYear: Int
    var title: String
    var popularity: Double?
    var address: String
    var lat: Double
    var long: Double
    var placeId: String
    
    private let baseStringURL = "http://image.tmdb.org/t/p/w500"
    
    init(json: JSON) {
        actors = json["actors"].arrayValue.map{$0.stringValue}
        
        description = json["description"].stringValue
        
        genreIds = json["genres"].arrayValue.map{$0["$numberInt"].intValue}
        
        id = json["tmdbid"]["$numberInt"].intValue
        
        let backdropImage = json["images"]["backdrop"].stringValue
        backdropImageURL = URL(string: baseStringURL + backdropImage)
        
        let posterImage = json["images"]["poster"].stringValue
        
        if posterImage.count > 0 {
            posterImageURL = URL(string: baseStringURL + posterImage)
        }

        company = json["production"]["company"].stringValue
        director = json["production"]["director"].stringValue
        writer = json["production"]["writer"].stringValue
        
        date = json["date"].stringValue
        releaseYear = json["year"]["$numberInt"].intValue
        
        title = json["title"].stringValue
        
        popularity = json["popularity"].doubleValue
        
        address = json["address"].stringValue
        lat = json["gps"]["lat"].doubleValue
        long = json["gps"]["long"].doubleValue
        placeId = json["placeId"].stringValue
    }
}
