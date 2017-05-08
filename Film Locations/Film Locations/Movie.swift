//
//  ExpandableObject.swift
//  Film Locations
//
//  Created by Laura on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import Foundation

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
    var locations: [Location]
    var isExpandable: Bool { return locations.count > 1 }
    var isExpanded: Bool
    var numberOfRows: Int { return locations.count }
    
    init(firebaseMovie: FirebaseMovie, locations: [Location], isExpanded: Bool) {
        
        self.actors = firebaseMovie.actors
        self.description = firebaseMovie.description
        self.genreIds = firebaseMovie.genreIds
        
        // unwraping the optional value is safe here because a check was done before creating the Movie object
        self.id = firebaseMovie.id!
        self.backdropImageURL = firebaseMovie.backdropImageURL
        self.posterImageURL = firebaseMovie.posterImageURL
        self.company = firebaseMovie.company
        self.director = firebaseMovie.director
        self.writer = firebaseMovie.writer
        self.date = firebaseMovie.date
        
        // unwraping the optional value is safe here because a check was done before creating the Movie object
        self.releaseYear = firebaseMovie.releaseYear!
        
        // unwraping the optional value is safe here because a check was done before creating the Movie object
        self.title = firebaseMovie.title!
        self.locations = locations
        self.isExpanded = isExpanded

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
