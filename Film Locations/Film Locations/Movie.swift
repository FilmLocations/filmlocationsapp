//
//  ExpandableObject.swift
//  Film Locations
//
//  Created by Laura on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import Foundation

class Movie {
    var id: Int
    var title: String
    var releaseYear: String
    var posterImageURL: URL?
    var locations: [Location]
    var isExpandable: Bool { return locations.count > 1 }
    var isExpanded: Bool
    var numberOfRows: Int { return locations.count }

    init(id: Int, title: String, releaseYear: String, posterImageURL: URL?, locations: [Location], isExpanded: Bool) {
        self.id = id
        self.title = title
        self.releaseYear = releaseYear
        self.posterImageURL = posterImageURL
        self.locations = locations
        self.isExpanded = isExpanded
    }
}
