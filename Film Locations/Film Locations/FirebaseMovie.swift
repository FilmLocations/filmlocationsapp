//
//  Movie.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import Foundation
import SwiftyJSON
import FirebaseDatabase

class FirebaseMovie {
    
    private let actorsKey = "actors"
    private let descriptionKey = "description"
    private let genreKey = "genre_ids"
    private let movieIdKey = "id"
    private let backdropKey = "images/backdrop"
    private let posterKey = "images/poster"
    private let addressKey = "location/address"
    private let latKey = "location/gps/location/lat"
    private let lngKey = "location/gps/location/lng"
    private let placeIdKey = "location/gps/place_id"
    private let companyKey = "production/company"
    private let directorKey = "production/director"
    private let writerKey = "production/writer"
    private let dateKey = "release/date"
    private let yearKey = "release/year"
    private let titleKey = "title"
    private let popularityKey = "popularity"
    
    private let baseStringURL = "http://image.tmdb.org/t/p/w500/"
    
    var actors: [String]?
    var description: String?
    var genreIds: [Int]?
    var id: Int?
    var backdropImageURL: URL? //String
    var posterImageURL: URL? //String
    var address: String?
    var lat: Double?
    var long: Double?
    var placeId: String?
    var company: String?
    var director: String?
    var writer: String?
    var date: String?
    var releaseYear: String?
    var title: String?
    var popularity: Int?
    
    init(snapshot: FIRDataSnapshot) {
        
        actors = snapshot.childSnapshot(forPath: actorsKey).value as? [String]
        description = snapshot.childSnapshot(forPath: descriptionKey).value as? String
        genreIds = snapshot.childSnapshot(forPath: genreKey).value as? [Int]
        id = snapshot.childSnapshot(forPath: movieIdKey).value as? Int
        
        if let backdropStringURL = snapshot.childSnapshot(forPath: backdropKey).value as? String {
            let backdropImageStringURL = baseStringURL + backdropStringURL
            backdropImageURL = URL(string: backdropImageStringURL)
        }
        
        if let posterStringURL = snapshot.childSnapshot(forPath: posterKey).value as? String {
            let posterImageStringURL = baseStringURL + posterStringURL
            posterImageURL = URL(string: posterImageStringURL)
        }
        
        address = snapshot.childSnapshot(forPath: addressKey).value as? String
        lat = snapshot.childSnapshot(forPath: latKey).value as? Double
        long = snapshot.childSnapshot(forPath: lngKey).value as? Double
        placeId = snapshot.childSnapshot(forPath: placeIdKey).value as? String
        company = snapshot.childSnapshot(forPath: companyKey).value as? String
        director = snapshot.childSnapshot(forPath: directorKey).value as? String
        writer = snapshot.childSnapshot(forPath: writerKey).value as? String
        date = snapshot.childSnapshot(forPath: dateKey).value as? String
        releaseYear = snapshot.childSnapshot(forPath: yearKey).value as? String
        title = snapshot.childSnapshot(forPath: titleKey).value as? String
        popularity = snapshot.childSnapshot(forPath: popularityKey).value as? Int
    }
}
