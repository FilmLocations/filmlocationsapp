//
//  ProfileHeaderView.swift
//  Film Locations
//
//  Created by Laura on 5/10/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    // Views that needs to be hidden at scroll up
    @IBOutlet weak var visitedView: UIView!
    @IBOutlet weak var visitedCounterLabel: UILabel!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesCounterLabel: UILabel!
    
    @IBOutlet weak var photosLabel: UILabel!
    
    var user: User? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        if user != nil && user?.screenname != "anonymous" {
            userNameLabel.text = user?.name
            userLocationLabel.text = user?.location
            
            if let profileImageURL = user?.profileUrl {
                profileImageView.setImageWith(profileImageURL)
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width/2
        profileImageView.layer.masksToBounds = true
    }
}
