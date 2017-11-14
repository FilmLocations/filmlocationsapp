//
//  ProfilePhotosCollectionViewCell.swift
//  Film Locations
//
//  Created by Laura on 5/10/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking

class ProfilePhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var locationImage: LocationImage? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        // removie existing info
        photoImageView.image = nil
        
        if let photo = locationImage {
            if let photoURL = URL(string: photo.imageName) {
                photoImageView.layer.cornerRadius = 4
                photoImageView.layer.masksToBounds = true
                photoImageView.setImageWith(photoURL)
            }
        }
    }
}
