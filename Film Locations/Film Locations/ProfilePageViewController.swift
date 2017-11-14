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
    @IBOutlet weak var transparentBackgroundView: UIView!
    @IBOutlet weak var visitedView: UIView!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var visitedCounterLabel: UILabel!
    @IBOutlet weak var favoriteCounterLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: MenuButtonPressDelegate?
    
    var user: User?
    
    var photos: [LocationImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = User.currentUser
        
        collectionView.dataSource = self
        collectionView.delegate = self

        transparentBackgroundView.backgroundColor = UIColor.fl_secondary
        transparentBackgroundView.alpha = 0.80
        
        visitedView.backgroundColor = UIColor.fl_secondary_700
        visitedView.alpha = 1
        visitedCounterLabel.textColor = UIColor.white
        
        favoritesView.backgroundColor = UIColor.fl_secondary_700
        favoritesView.alpha = 1
        favoriteCounterLabel.textColor = UIColor.white
        
        collectionView.backgroundColor = UIColor.white
        collectionView.alpha = 1
        
        userNameLabel.textColor = UIColor.white
        userLocationLabel.textColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Database.sharedInstance.getUserImageMetadata(userId: (user?.screenname)!) { (locationImages) in
            self.photos = locationImages
            self.collectionView.reloadData()
        }
        Database.sharedInstance.userVisitsCount(userId: (user?.screenname)!, completion: { (visitedCounter) in
            self.visitedCounterLabel.text = "\(visitedCounter)"
        })
        
        Database.sharedInstance.userLikesCount(userId: (user?.screenname)!) { (favoriteCounter) in
            self.favoriteCounterLabel.text = "\(favoriteCounter)"
        }
        
        updateUI()
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }

    private func updateUI() {
        
        if user != nil && user?.screenname != "anonymous" {
            userNameLabel.text = user?.name
            userLocationLabel.text = user?.location
            
            if let profileImageURL = user?.profileUrl {
                backgroundImageView.backgroundColor = UIColor.white
                backgroundImageView.setImageWith(profileImageURL)
                //            backgroundImageView.image = backgroundImageView.image?.blurredImage(withRadius: 5, iterations: 5, tintColor: nil)
                profileImageView.setImageWith(profileImageURL)
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width/2
        profileImageView.layer.masksToBounds = true

        borderView.layer.cornerRadius = borderView.bounds.size.width/2
        borderView.layer.masksToBounds = true
    }
}

extension ProfilePageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! ProfilePhotosCollectionViewCell
        
        Database.sharedInstance.getLocationImage(filename: photos[indexPath.row].imageName, completion: { (image) in
            cell.photoImageView.image = image
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Fullscreen", bundle: nil)
        
        let fullscreen = storyboard.instantiateViewController(withIdentifier: "Fullscreen") as! FullscreenViewController
        
        let nav = UINavigationController(rootViewController: fullscreen)
        nav.navigationBar.barTintColor = UIColor.fl_primary_dark
        
        fullscreen.locationImageMetadata = photos[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! ProfilePhotosCollectionViewCell
        fullscreen.locationImage = cell.photoImageView.image
        
        self.present(nav, animated: true, completion: nil)
    }
    
}
