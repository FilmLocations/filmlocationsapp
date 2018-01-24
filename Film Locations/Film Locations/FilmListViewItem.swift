//
//  FilmListViewItem.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 1/23/18.
//  Copyright © 2018 Codepath Spring17. All rights reserved.
//

import Foundation

class FilmListViewItem {
    
    var id: Int
    var date: String?
    var releaseYear: String
    var title: String
    var popularity: Double?
    var posterImageURL: URL?
    var addresses = [String]()
    var isExpanded = false
    
    init(location: FilmLocation) {
        self.id = location.id
        self.date = location.date
        self.releaseYear = location.releaseYear
        self.title = location.title
        self.popularity = location.popularity
        self.posterImageURL = location.posterImageURL
        self.addresses.append(location.address)
    }
    
}
