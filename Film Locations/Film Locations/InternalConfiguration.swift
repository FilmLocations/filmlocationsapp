//
//  InternalConfiguration.swift
//  Film Locations
//
//  Created by Laura on 4/27/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import Foundation

struct InternalConfiguration {
    static let mapToggleIcon = "mapToggleIcon"
    static let listToggleIcon = "listToggleIcon"
    
    static let moviesArray = [
        FirebaseMovie(title: "180", releaseYear: "2011", posterImageURL: URL(string: "http://image.tmdb.org/t/p/w500//2ztXNTrtoe7Q9LcLVbcgSkHizUK.jpg")!, locationImageURL: URL(string: "http://image.tmdb.org/t/p/w500//rQS1bIsXTiZwiwTJ6vI5PHinvK2.jpg")!, address: "Epic Roasthouse (399 Embarcadero)", distance: 0.3),
        FirebaseMovie(title: "180", releaseYear: "2011", posterImageURL: URL(string: "http://image.tmdb.org/t/p/w500//2ztXNTrtoe7Q9LcLVbcgSkHizUK.jpg")!, locationImageURL: URL(string: "http://image.tmdb.org/t/p/w500//qey0tdcOp9kCDdEZuJ87yE3crSe.jpg")!, address: "Mason & California Streets (Nob Hill)", distance: 0.7),
        
        FirebaseMovie(title: "Age of Adaline", releaseYear: "2015", posterImageURL: URL(string: "http://image.tmdb.org/t/p/w500//gEDGROZ4NQDlRjUPPSSyIf0hKvD.jpg")!, locationImageURL: URL(string: "http://image.tmdb.org/t/p/w500//iAsnIAyoauaGYmQwh2JOd1ibhke.jpg")!, address: "Pier 50- end of the pier", distance: 0.5)]
}
