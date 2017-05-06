//
//  MoviePosterView.swift
//  Film Locations
//
//  Created by Niraj Pendal on 4/30/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import GooglePlaces

struct MoviePosterViewDataSource {
    var movie: MapMovie
    var displaySearchData = false
    var referenceLocation: CLLocation
}

class MoviePosterView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    
    var moviePosterDataSource: MoviePosterViewDataSource! {
        didSet{
            self.yearLabel.attributedText = InternalConfiguration.customizeTextAppearance(text: "(\(moviePosterDataSource.movie.releaseYear))")
            self.titleLabel.attributedText  = InternalConfiguration.customizeTextAppearance(text: moviePosterDataSource.movie.title)
            if !moviePosterDataSource.displaySearchData {
                self.posterImageView.setImageWith(moviePosterDataSource.movie.posterImageURL!)
            } else {
                self.posterImageView.image = UIImage(named: "Place-Dummy")
                loadFirstPhotoForPlace(placeID: moviePosterDataSource.movie.location.placeId)
            }
            
            let movieLocation = CLLocation(latitude: moviePosterDataSource.movie.location.lat, longitude: moviePosterDataSource.movie.location.long)
            
            let distance = moviePosterDataSource.referenceLocation.distance(from: movieLocation)
            
            self.distanceLabel.attributedText = InternalConfiguration.customizeTextAppearance(text: "\(String(format: "%.2f", metersToMiles(distance:distance))) miles")
        }
    }
    
    func metersToMiles(distance: Double) -> Double {
            return round(distance) * 0.000621371
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "MoviePosterView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.posterImageView.image = photo
            }
        })
    }


}
