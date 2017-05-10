//
//  ProfilePageViewController.swift
//  Film Locations
//
//  Created by Laura on 5/4/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking
import FXBlurView

class ProfilePageViewController: UIViewController, MenuContentViewControllerProtocol {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var visitedCounterLabel: UILabel!
    @IBOutlet weak var favoriteCounterLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: MenuButtonPressDelegate?
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = User.currentUser
        
        updateUI()
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }

    func updateUI() {
        
        if user != nil && user?.screenname != "anonymous" {
            userNameLabel.text = user?.name
            userLocationLabel.text = user?.location
            
            if let profileImageURL = user?.profileUrl {
                backgroundImageView.setImageWith(profileImageURL)
                //            backgroundImageView.image = backgroundImageView.image?.blurredImage(withRadius: 5, iterations: 5, tintColor: nil)
                profileImageView.setImageWith(profileImageURL)
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width/2
        profileImageView.layer.masksToBounds = true
    }
}
