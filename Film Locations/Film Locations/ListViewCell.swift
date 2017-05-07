//
//  ListViewCell.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking
import FXBlurView

class ListViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var numberOfLocationsLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    

    var movie: Movie? {
        didSet {
            updateUI()
        }
    }

    func updateUI() {

        // reset any existing movie information
        titleLabel.text = nil
        yearLabel.text = nil
        numberOfLocationsLabel.text = nil
        posterImageView.image = nil
        
        if let movie = movie {
            
            titleLabel.attributedText = InternalConfiguration.customizeTextAppearance(text: movie.title)
            yearLabel.attributedText = InternalConfiguration.customizeTextAppearance(text: movie.releaseYear)
                        
            var numberOfLocation = "\(movie.locations.count)"
            if movie.locations.count == 1 {
                numberOfLocation = numberOfLocation + " LOCATION"
            }
            else {
                numberOfLocation = numberOfLocation + " LOCATIONS"
            }
            
            numberOfLocationsLabel.attributedText = InternalConfiguration.customizeTextAppearance(text: numberOfLocation)
            
            if let posterImageURL = movie.posterImageURL {
                posterImageView.setImageWith(posterImageURL)
                posterImageView.image = posterImageView.image?.blurredImage(withRadius: 2, iterations: 5, tintColor: nil)
            }
        }
    }
}
