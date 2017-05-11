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
    
//    @IBOutlet weak var profileHeader: ProfileHeaderView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: MenuButtonPressDelegate?
    
    var user: User? {
        didSet {
            updateUI()
        }
    }
    var photos: [LocationImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = User.currentUser
        
        Database.sharedInstance.getUserImageMetadata(userId: (user?.screenname)!) { (locationImages) in
            self.photos = locationImages
            print("photos number: \(self.photos.count), \(self.photos[0].imageURL)")
            self.collectionView.reloadData()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        updateUI()
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }

    func updateUI() {
        if viewIfLoaded == nil {
            return
        }

        if user != nil && user?.screenname != "anonymous" {
            if let profileImageURL = user?.profileUrl {
                backgroundImageView.setImageWith(profileImageURL)
                //            backgroundImageView.image = backgroundImageView.image?.blurredImage(withRadius: 5, iterations: 5, tintColor: nil)
            }
        }
    }
}

extension ProfilePageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        
        switch kind {
        
        case UICollectionElementKindSectionHeader:
        
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "ProfileHeaderView",
                                                                             for: indexPath) as! ProfileHeaderView
            headerView.user = user
            return headerView
        default:
        
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("photos.count in nbOfItemsInSection: \(photos.count)")
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! ProfilePhotosCollectionViewCell
        cell.locationImage = photos[indexPath.row]
        print("cell.locationImage in cellForRow: \(cell.locationImage?.imageURL)")
        return cell
    }
}

//extension ProfilePageViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        let offset = scrollView.contentOffset.y + profileHeader.headerView.bounds.height / 4 + profileHeader.visitedView.bounds.height + profileHeader.photosLabel.bounds.height
//        
//        print("offset: \(offset)")
//        
//        var headerTransform = CATransform3DIdentity
//        
//        // PULL DOWN -----------------
//        
//        if offset < 0 {
//            
//            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
//            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
//            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
//            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
//            
//            
//            // Hide views if scrolled super fast
//            headerView.layer.zPosition = 0
//            headerLabel.isHidden = true
//            
//        }
//            
//            // SCROLL UP/DOWN ------------
//            
//        else {
//            
//            // Header -----------
//            
//            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
//            
//            //  ------------ Label
//            
//            headerLabel.isHidden = false
//            let alignToNameLabel = -offset + handleLabel.frame.origin.y + headerView.frame.height + offset_HeaderStop
//            
//            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
//            
//            
//            //  ------------ Blur
//            
//            headerBlurImageView?.alpha = min (1.0, (offset - alignToNameLabel)/distance_W_LabelHeader)
//            
//            // Avatar -----------
//            
//            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 9.4 // Slow down the animation
//            print(avatarScaleFactor)
//            
//            let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
//            print(avatarSizeVariation)
//            
//            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
//            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
//            
//            if offset <= offset_HeaderStop {
//                
//                if avatarImage.layer.zPosition < headerView.layer.zPosition{
//                    headerView.layer.zPosition = 0
//                }
//                
//                
//            }else {
//                if avatarImage.layer.zPosition >= headerView.layer.zPosition{
//                    headerView.layer.zPosition = 2
//                }
//                
//            }
//            
//        }
//        
//        // Apply Transformations
//        headerView.layer.transform = headerTransform
//        avatarImage.layer.transform = avatarTransform
//        
//    }
//}
