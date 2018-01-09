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
    var location: FilmLocation
    var displaySearchData = false
    var referenceLocation: CLLocation
}

protocol MoviePosterViewDelegate: class {
    func didTapOnImage(selectedLocation: FilmLocation)
}

class MoviePosterView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var topLeftVisualView: UIVisualEffectView!
    @IBOutlet weak var bottonLeftVisualView: UIVisualEffectView!
    
    weak var delegate: MoviePosterViewDelegate?
    
    var moviePosterDataSource: MoviePosterViewDataSource! {
        didSet {
            yearLabel.attributedText = InternalConfiguration.customizeTextAppearance1(text: "(\(moviePosterDataSource.location.releaseYear))")
            titleLabel.attributedText  = InternalConfiguration.customizeTextAppearance1(text: moviePosterDataSource.location.title)
            if !moviePosterDataSource.displaySearchData {
                posterImageView.setImageWith(moviePosterDataSource.location.posterImageURL!)
            } else {
                posterImageView.image = UIImage(named: "Place-Dummy")
                fetchImageForPoster(placeID: moviePosterDataSource.location.placeId)
            }
            
            let movieLocation = CLLocation(latitude: moviePosterDataSource.location.lat, longitude: moviePosterDataSource.location.long)
            
            let distance = moviePosterDataSource.referenceLocation.distance(from: movieLocation)
            
            distanceLabel.attributedText = InternalConfiguration.customizeTextAppearance1(text: "\(String(format: "%.2f", metersToMiles(distance:distance))) miles")
        }
    }
    
    func fetchImageForPoster(placeID: String) {
        
        Database.sharedInstance.getLocationImageMetadata(placeId: placeID) { locationImages in
            
            if locationImages.count > 0 {
                Database.sharedInstance.getLocationImage(filename: locationImages[0].imageName, completion: { locationImage in
                    self.posterImageView.image = locationImage
                })
            } else {
                Utility.loadFirstPhotoForPlace(placeID: placeID, callback: { (image:UIImage?) in
                    if let image = image {
                        self.posterImageView.image = image
                    } else {
                        Utility.loadRandomPhotoForPlace(placeID: "ChIJIQBpAG2ahYAR_6128GcTUEo", callback: { (image:UIImage?) in
                            if let image = image {
                                self.posterImageView.image = image
                            }
                        })
                    }
                })
            }
        }
    }
    
    func metersToMiles(distance: Double) -> Double {
        return round(distance) * 0.000621371
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
        setUp()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "MoviePosterView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnImageView(sender:)))
        tapGesture.delegate = self
        posterImageView.addGestureRecognizer(tapGesture)
        
        bottonLeftVisualView.layer.cornerRadius = 15
        bottonLeftVisualView.clipsToBounds = true
        
        topLeftVisualView.layer.cornerRadius = 15
        topLeftVisualView.clipsToBounds = true
    }
    
    func setUp() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10
        backgroundColor = UIColor.clear
    }
    
    let borderWidth = 0.8
    let cornerRadius:Double = 10
    var borderColor: UIColor = UIColor.gray
    
    override func draw(_ rect: CGRect) {
        
        UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).fill()
        
        let borderRect = bounds.insetBy(dx: CGFloat(borderWidth/2), dy: CGFloat(borderWidth/2))
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: CGFloat(cornerRadius - borderWidth/2))
        borderColor.setStroke()
        borderPath.lineWidth = CGFloat(borderWidth)
        borderPath.stroke()
    }
}

extension MoviePosterView : UIGestureRecognizerDelegate {
    
    @objc func didTapOnImageView(sender: UITapGestureRecognizer){
        delegate?.didTapOnImage(selectedLocation: moviePosterDataSource.location)
    }
}
