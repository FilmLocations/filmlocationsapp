//
//  FilmDetailsViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking
import WCLShineButton
import LyftSDK
import CoreLocation
import BRYXBanner

class FilmDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var numberOfVisitsLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfUploadsLabel: UILabel!
    @IBOutlet weak var visitLocationView: UIView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var lyftButton: LyftButton!
    @IBOutlet weak var miniPosterImage: UIImageView!
    @IBOutlet weak var uploadsNameLabel: UILabel!
    @IBOutlet weak var visitsNameLabel: UILabel!
    @IBOutlet weak var likesNameLabel: UILabel!

    var location: FilmLocation! {
        didSet {
            updateUI()
        }
    }
    
    var user: User!
    var locationImages: [LocationImage]!
    
    var visitButton: WCLShineButton!
    var likeButton: WCLShineButton!
    
    var visitsCount = 0
    var likesCount = 0
    
    var hasTriedLoadingUserImages = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up action buttons
        var shineParams = WCLShineParams()
        shineParams.bigShineColor = UIColor.fl_accent!
        shineParams.smallShineColor = UIColor.fl_primary!
        likeButton = WCLShineButton(frame: .init(x: 25, y: 5, width: 38, height: 38), params: shineParams)
        likeButton.fillColor = UIColor(rgb: (196,23,1))
        likeButton.color = UIColor.fl_primary!
        likeButton.image = .custom(#imageLiteral(resourceName: "heart"))
        likeButton.addTarget(self, action: #selector(LikeLocation(_:)), for: .touchUpInside)
        likesView.addSubview(likeButton)
        
        visitButton = WCLShineButton(frame: .init(x: 22, y: 4, width: 40, height: 40), params: shineParams)
        visitButton.fillColor = UIColor.fl_accent!
        visitButton.color = UIColor.fl_primary!
        visitButton.image = .custom(#imageLiteral(resourceName: "check"))
        visitButton.addTarget(self, action: #selector(visitLocation(_:)), for: .touchUpInside)
        visitLocationView.addSubview(visitButton)
        
        let origImage = #imageLiteral(resourceName: "plus")
        let tintedImage = origImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        addPhotoButton.setImage(tintedImage, for: .normal)
        addPhotoButton.tintColor = UIColor.fl_primary
        
        // Do any additional setup after loading the view.
        user = User.currentUser
        
        Database.sharedInstance.getLocationImageMetadata(placeId: location.placeId) { locationImages in
            
            if locationImages.count > 0 {
                Database.sharedInstance.getLocationImage(filename: locationImages[0].imageName, completion: { locationImage in
                    self.topBackgroundImageView.image = locationImage
                })
                
                self.locationImages = locationImages
                self.photosCollectionView.reloadData()
                self.updateCounts()
                self.hasTriedLoadingUserImages = true
            } else {
                self.photosCollectionView.reloadData()
                self.hasTriedLoadingUserImages = true
            }
        }
        
        //TODO pass current location as pickup, otherwise destination has no effect
        var pickup = CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4)
        if let userCurrentLocation = UserDefaults.standard.dictionary(forKey: "kUserCurrentPreferncesKey") {
            pickup = CLLocationCoordinate2D(latitude: userCurrentLocation["lat"] as! CLLocationDegrees, longitude: userCurrentLocation["long"] as! CLLocationDegrees)
        }
        
        let destination = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
        lyftButton.style = .mulberryDark
        lyftButton.configure(rideKind: LyftSDK.RideKind.Line, pickup: pickup, destination: destination)
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        if (user.isAnonymous) {
            let visitButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onVisitButtonTapped(_:)))
            let likeButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onLikeButtonTapped(_:)))

            visitButtonGestureRecognizer.delegate = self
            likeButtonGestureRecognizer.delegate = self
            visitLocationView.addGestureRecognizer(visitButtonGestureRecognizer)
            likesView.addGestureRecognizer(likeButtonGestureRecognizer)
        }

        updateUI()

        addBackButton()

        view.backgroundColor = UIColor.white
        likesView.backgroundColor = UIColor.white
        visitLocationView.backgroundColor = UIColor.white
        photosCollectionView.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.fl_primary_light
        overviewLabel.textColor = UIColor.fl_primary_light
        numberOfUploadsLabel.textColor = UIColor.fl_primary_text
        numberOfVisitsLabel.textColor = UIColor.fl_primary_text
        numberOfLikesLabel.textColor = UIColor.fl_primary_text
        numberOfUploadsLabel.backgroundColor = UIColor.fl_accent
        numberOfLikesLabel.backgroundColor = UIColor.fl_accent
        numberOfVisitsLabel.backgroundColor = UIColor.fl_accent
        uploadsNameLabel.backgroundColor = UIColor.fl_accent
        visitsNameLabel.backgroundColor = UIColor.fl_accent
        likesNameLabel.backgroundColor = UIColor.fl_accent
        uploadsNameLabel.textColor = UIColor.fl_primary_text
        visitsNameLabel.textColor = UIColor.fl_primary_text
        likesNameLabel.textColor = UIColor.fl_primary_text
        addressLabel.textColor = UIColor.fl_primary_text
        navigationController?.navigationBar.tintColor = UIColor.fl_primary_text
        navigationController?.navigationBar.barTintColor = UIColor.fl_primary_dark
    }
    
    override func viewDidAppear(_ animated: Bool) {

        Database.sharedInstance.getLocationImageMetadata(placeId: location.placeId) { locationImages in
            
            if self.locationImages != nil && locationImages.count != self.locationImages.count {
            
                if locationImages.count > 0 {
                    Database.sharedInstance.getLocationImage(filename: locationImages[0].imageName, completion: {(locationImage) in
                        self.topBackgroundImageView.image = locationImage
                    })

                    self.locationImages = locationImages
                    self.photosCollectionView.reloadData()
                    self.updateCounts()
                }
            }
        }
    }

    private func addBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(onBackButtonPress(_:)))
    }
    
    @objc func onBackButtonPress(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onVisitButtonTapped(_ sender: UIView) {
        if user.isAnonymous {
            let banner = Banner(title: "Login", subtitle: "Please login to mark this location as visited", image: nil, backgroundColor: UIColor.fl_accent!)
            banner.textColor = UIColor.fl_primary_text!
            banner.dismissesOnTap = true
            banner.show(duration: 4.0)
        }
    }

    @objc func onLikeButtonTapped(_ sender: UIView) {
        if user.isAnonymous {
            let banner = Banner(title: "Login", subtitle: "Please login to like this location", image: nil, backgroundColor: UIColor.fl_accent!)
            banner.textColor = UIColor.fl_primary_text!
            banner.dismissesOnTap = true
            banner.show(duration: 4.0)
        }
    }

    private func updateUI() {
    
        if viewIfLoaded == nil {
            return
        }

        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 4
        miniPosterImage.clipsToBounds = true
        miniPosterImage.layer.cornerRadius = 4
        addressVisualEffectView.layer.cornerRadius = 10
        addressVisualEffectView.clipsToBounds = true
        
        if let movie = location {
            if let posterImageURL = movie.posterImageURL {
                posterImageView.setImageWith(posterImageURL)
                miniPosterImage.setImageWith(posterImageURL)
            }
            addressLabel.text = movie.address
            titleLabel.text = "\(movie.title) (\(movie.releaseYear))"
            overviewLabel.text = movie.description
        }
        
        // Anonymous users can't mark as visited or like
        if user.isAnonymous {
            visitButton.isUserInteractionEnabled = false
            likeButton.isUserInteractionEnabled = false
        } else {
            Database.sharedInstance.hasVisitedLocation(userId: user.screenname, locationId: location.placeId) { hasVisited in
                    self.visitButton.isSelected = hasVisited
            }

            Database.sharedInstance.hasLikedLocation(userId: user.screenname, locationId: location.placeId) { hasLiked in
                    self.likeButton.isSelected = hasLiked
            }
        }

        updateCounts()
    }

    private func updateCounts() {

        Database.sharedInstance.locationLikesCount(placeId: location.placeId) { count in
            self.likesCount = count
            self.numberOfLikesLabel.text = String(count)
        }
        Database.sharedInstance.locationVisitsCount(placeId: location.placeId) { count in
            self.visitsCount = count
            self.numberOfVisitsLabel.text = String(count)
        }

        if let locationImages = locationImages {
            numberOfUploadsLabel.text = String(locationImages.count)
        } else {
            numberOfUploadsLabel.text = "0"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapTopImage(_ sender: UITapGestureRecognizer) {
        openFullscreenView(indexPath: nil)
    }
    
    func openFullscreenView(indexPath: IndexPath?) {
        let storyboard = UIStoryboard(name: "Fullscreen", bundle: nil)
        
        let fullscreen = storyboard.instantiateViewController(withIdentifier: "Fullscreen") as! FullscreenViewController
        
        let nav = UINavigationController(rootViewController: fullscreen)
        nav.navigationBar.barTintColor = UIColor.fl_primary_dark
        
        if let indexPath = indexPath {
            if (locationImages != nil) {
                fullscreen.locationImageMetadata = locationImages[indexPath.row]
            }
            
            let cell = photosCollectionView.cellForItem(at: indexPath as IndexPath) as! LocationPhotoCollectionViewCell
            fullscreen.locationImage = cell.locationPhotoImageView.image
        
        } else {
            if (locationImages != nil) {
                fullscreen.locationImageMetadata = locationImages[0]
            }
            fullscreen.locationImage = topBackgroundImageView.image
        }
        
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {      
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            vc.sourceType = .camera
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            vc.sourceType = .photoLibrary
        }
        
        present(vc, animated: true, completion: nil)
    }

    @IBAction func visitLocation(_ sender: UIButton) {
        if visitButton.isSelected {
            Database.sharedInstance.removeVisitLocation(userId: user.screenname, locationId: location.placeId, completion: { completion in
                self.visitsCount = self.visitsCount - 1
                self.numberOfVisitsLabel.text = String(self.visitsCount)
            })
        } else {
            Database.sharedInstance.visitLocation(userId: user.screenname, locationId: location.placeId, completion: { completion in
                self.visitsCount = self.visitsCount + 1
                self.numberOfVisitsLabel.text = String(self.visitsCount)
            })
        }
    }

    @IBAction func LikeLocation(_ sender: UIButton) {
        if likeButton.isSelected {
            Database.sharedInstance.removeLikeLocation(userId: user.screenname, locationId: location.placeId, completion: { completion in
                self.likesCount = self.likesCount - 1
                self.numberOfLikesLabel.text = String(self.likesCount)
            })
        } else {
            Database.sharedInstance.likeLocation(userId: user.screenname, locationId: location.placeId, completion: { completion in
                self.likesCount = self.likesCount + 1
                self.numberOfLikesLabel.text = String(self.likesCount)
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Go to post edit view
        dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Post", bundle: nil)
    
            let pvc = storyboard.instantiateViewController(withIdentifier: "Post") as! PostViewController
            pvc.postImage = editedImage
            pvc.postPlaceId = self.location.placeId

            self.present(pvc, animated: true, completion: nil)
        }
    }
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension FilmDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = locationImages {
            return images.count
        } else {
            if (hasTriedLoadingUserImages) {
                return 1
            } else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationPhotoCollectionViewCell", for: indexPath) as! LocationPhotoCollectionViewCell
        
        if (locationImages != nil && locationImages.count > 0) {
            Database.sharedInstance.getLocationImage(filename: locationImages[indexPath.row].imageName, completion: { image in
                cell.locationPhotoImageView.image = image
            })
        } else {
            if (hasTriedLoadingUserImages) {
                Utility.loadFirstPhotoForPlace(placeID: location.placeId, callback: { image in
                    
                    if image != nil {
                        cell.locationPhotoImageView.image = image
                        self.topBackgroundImageView.image = image
                    } else {
                        Utility.loadRandomPhotoForPlace(placeID: "ChIJIQBpAG2ahYAR_6128GcTUEo", callback: { (image:UIImage?) in
                            cell.locationPhotoImageView.image = image
                            self.topBackgroundImageView.image = image
                        })
                    }
                })
            }
        }
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openFullscreenView(indexPath: indexPath)
    }
}
