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
    
    @IBOutlet weak var transparentBackgroundView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var visitedCounterLabel: UILabel!
    @IBOutlet weak var favoriteCounterLabel: UILabel!
    @IBOutlet weak var twitterHandleLabel: UILabel!
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
        collectionView.backgroundColor = UIColor.fl_primary
        view.backgroundColor = UIColor.fl_primary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let user = user else {
            return
        }
        
        if (user.isAnonymous) {
            twitterHandleLabel.isHidden = true
        } else {
//            Database.shared.getUserImageMetadata(userId: user.screenname) { locationImages in
//                if (locationImages.count != self.photos.count) {
//                    self.photos = locationImages
//                    self.collectionView.reloadData()
//                }
//            }
            
            Database.shared.userVisitsCount(userId: user.screenname) { visitedCounter in
                if (visitedCounter == 1) {
                    self.visitedCounterLabel.text = "\(visitedCounter) visit"
                } else {
                    self.visitedCounterLabel.text = "\(visitedCounter) visits"
                }
            }
            
            Database.shared.userLikesCount(userId: user.screenname) { favoriteCounter in
                if (favoriteCounter == 1) {
                    self.favoriteCounterLabel.text = "\(favoriteCounter) like"
                } else {
                    self.favoriteCounterLabel.text = "\(favoriteCounter) likes"
                }
            }
        }
        
        updateUI()
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }

    private func updateUI() {
        
        if let user = user {
            if (!user.isAnonymous) {
                userNameLabel.text = user.name
                twitterHandleLabel.text = "@\(user.screenname!)"
                
                if let profileImageURL = user.profileImageURL {
                    profileImageView.setImageWith(URL(string: profileImageURL)!)
                }
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width/2
        profileImageView.layer.masksToBounds = true

        borderView.layer.cornerRadius = borderView.bounds.size.width/2
        borderView.layer.masksToBounds = true
    }
}

extension ProfilePageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionHeaderView", for: indexPath)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! ProfilePhotosCollectionViewCell
        
        Database.shared.getLocationImage(filename: photos[indexPath.row].imageName, completion: { (image) in
            cell.photoImageView.image = image
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Fullscreen", bundle: nil)
        
        let fullscreen = storyboard.instantiateViewController(withIdentifier: "Fullscreen") as! FullscreenViewController
        
        let nav = UINavigationController(rootViewController: fullscreen)
        
        fullscreen.locationImageMetadata = photos[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! ProfilePhotosCollectionViewCell
        fullscreen.locationImage = cell.photoImageView.image
        
        present(nav, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.frame.width / 3) - 1, height: (view.frame.width / 3) - 1) 
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
}
