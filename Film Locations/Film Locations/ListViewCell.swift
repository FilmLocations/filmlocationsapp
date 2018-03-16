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
    @IBOutlet weak var locationsVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var posterImageNotAvailableLabel: UILabel!
    
    var movie: FilmListViewItem? {
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
        posterImageNotAvailableLabel.isHidden = true
        
        if let movie = movie {
            locationsVisualEffectView.layer.cornerRadius = 3
            locationsVisualEffectView.clipsToBounds = true
            locationsVisualEffectView.contentView.backgroundColor = UIColor.fl_secondary
            
            titleLabel.text = movie.title
            yearLabel.text = String(movie.releaseYear)
            
            var numberOfLocations = ""
            if movie.addresses.count == 1 {
                numberOfLocations = "1 Location"
            }
            else {
                numberOfLocations = "\(movie.addresses.count) Locations"
            }
            
            numberOfLocationsLabel.text = numberOfLocations
            
            if let posterImageURL = movie.posterImageURL {
                posterImageView.setImageWith(posterImageURL)
            } else {
                posterImageNotAvailableLabel.isHidden = false
            }
        }
    }
}
