//
//  ListViewCell.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking

class ListViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var numberOfLocationsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    

    var movie: Movie? {
        didSet {
            updateUI()
        }
    }

    func updateUI() {

        if let movie = movie {
            
            titleLabel.text = movie.title
            yearLabel.text = movie.releaseYear
                        
            let numberOfLocation = movie.locations.count
            if numberOfLocation == 1 {
                locationLabel.text = "Location"
            }
            else {
                locationLabel.text = "Locations"
            }
            numberOfLocationsLabel.text = "\(numberOfLocation)"
            
            posterImageView.setImageWith(movie.posterImageURL)
            
        }
    }
}
