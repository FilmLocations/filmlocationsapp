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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: MenuButtonPressDelegate?
    
    var user: User?
    var photos: [LocationImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = User.currentUser
        
        Database.sharedInstance.getUserImageMetadata(userId: (user?.screenname)!) { (locationImages) in
            self.photos = locationImages
        }
        
        
        updateUI()
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }

    func updateUI() {
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

//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
//        //1
//        switch kind {
//        //2
//        case UICollectionElementKindSectionHeader:
//            //3
////            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
////                                                                             withReuseIdentifier: "FlickrPhotoHeaderView",
////                                                                             for: indexPath) as! FlickrPhotoHeaderView
//            headerView.label.text = searches[(indexPath as NSIndexPath).section].searchTerm
//            return headerView
//        default:
//            //4
//            assert(false, "Unexpected element kind")
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! ProfilePhotosCollectionViewCell
        
        return cell
    }
}
