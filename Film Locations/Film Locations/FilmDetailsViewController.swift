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
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var visitLocationView: UIView!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var lyftButton: LyftButton!
    @IBOutlet weak var miniPosterImage: UIImageView!
    @IBOutlet weak var uploadsNameLabel: UILabel!
    @IBOutlet weak var visitsNameLabel: UILabel!
    @IBOutlet weak var likesNameLabel: UILabel!

    var movie: Movie? {
        didSet {
            updateUI()
        }
    }
    
    var user: User!
    
    var locationIndex: Int!
    var locationImages: [LocationImage]!
    
    var visitButton: WCLShineButton!
    var likeButton: WCLShineButton!
    var addPhotoButton: WCLShineButton!
    
    var visitsCount = 0
    var likesCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up action buttons
        var param1 = WCLShineParams()
        param1.bigShineColor = UIColor(rgb: (196,23,1))
        param1.smallShineColor = UIColor(rgb: (102,102,102))
        param1.enableFlashing = true
        likeButton = WCLShineButton(frame: .init(x: 25, y: 5, width: 32, height: 32), params: param1)
        likeButton.fillColor = UIColor(rgb: (196,23,1))
        likeButton.color = UIColor(rgb: (170,170,170))
        likeButton.image = .custom(#imageLiteral(resourceName: "heart"))
        likeButton.addTarget(self, action: #selector(LikeLocation(_:)), for: .touchUpInside)
        likesView.addSubview(likeButton)
        
        var param2 = WCLShineParams()
        param2.bigShineColor = UIColor(rgb: (153,152,38))
        param2.smallShineColor = UIColor(rgb: (102,102,102))
        param2.enableFlashing = true
        visitButton = WCLShineButton(frame: .init(x: 25, y: 5, width: 32, height: 32), params: param1)
        visitButton.fillColor = UIColor.fl_accent!
        visitButton.color = UIColor(rgb: (170,170,170))
        visitButton.image = .custom(#imageLiteral(resourceName: "check"))
        visitButton.addTarget(self, action: #selector(visitLocation(_:)), for: .touchUpInside)
        visitLocationView.addSubview(visitButton)
        
        var param3 = WCLShineParams()
        param3.bigShineColor = UIColor(rgb: (153,152,38))
        param3.smallShineColor = UIColor(rgb: (102,102,102))
        param3.enableFlashing = true
        addPhotoButton = WCLShineButton(frame: .init(x: 25, y: 5, width: 32, height: 32), params: param1)
        addPhotoButton.color = UIColor(rgb: (170,170,170))
        addPhotoButton.image = .custom(#imageLiteral(resourceName: "plus"))
        addPhotoButton.addTarget(self, action: #selector(addPhoto(_:)), for: .touchUpInside)
        addPhotoView.addSubview(addPhotoButton)
        
        // Do any additional setup after loading the view.
        user = User.currentUser
        
        let placeId = movie!.locations[locationIndex].placeId
        let location = movie!.locations[locationIndex]
        Database.sharedInstance.getLocationImageMetadata(placeId: placeId) { (locationImages) in
            
            if locationImages.count > 0 {
                Database.sharedInstance.getLocationImage(url: locationImages[0].imageURL, completion: {(locationImage) in
                    self.topBackgroundImageView.image = locationImage
                })
                
                if self.locationImages != nil {
                    self.locationImages = nil
                }
                
                self.locationImages = locationImages
                self.photosCollectionView.reloadData()
                self.updateCounts()
            }
        }
        
        //TODO pass current location as pickup, otherwise destination has no effect
        var pickup = CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4)
        if let userCurrentLocation = UserDefaults.standard.dictionary(forKey: "kUserCurrentPreferncesKey") {
            pickup = CLLocationCoordinate2D(latitude: userCurrentLocation["lat"] as! CLLocationDegrees, longitude: userCurrentLocation["long"] as! CLLocationDegrees)
        }
        
        let destination = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
        lyftButton.style = .mulberryLight
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

        view.backgroundColor = UIColor.fl_primary_dark
        likesView.backgroundColor = UIColor.fl_primary_dark
        visitLocationView.backgroundColor = UIColor.fl_primary_dark
        addPhotoView.backgroundColor = UIColor.fl_primary_dark
        photosCollectionView.backgroundColor = UIColor.fl_primary_dark
        lyftButton.backgroundColor = UIColor.fl_primary_dark
        titleLabel.textColor = UIColor.fl_primary_light
        overviewLabel.textColor = UIColor.fl_primary_light
        numberOfUploadsLabel.textColor = UIColor.fl_secondary_text
        numberOfVisitsLabel.textColor = UIColor.fl_secondary_text
        numberOfLikesLabel.textColor = UIColor.fl_secondary_text
        numberOfUploadsLabel.backgroundColor = UIColor.fl_accent
        numberOfLikesLabel.backgroundColor = UIColor.fl_accent
        numberOfVisitsLabel.backgroundColor = UIColor.fl_accent
        uploadsNameLabel.backgroundColor = UIColor.fl_accent
        visitsNameLabel.backgroundColor = UIColor.fl_accent
        likesNameLabel.backgroundColor = UIColor.fl_accent
        uploadsNameLabel.textColor = UIColor.fl_secondary_text
        visitsNameLabel.textColor = UIColor.fl_secondary_text
        likesNameLabel.textColor = UIColor.fl_secondary_text
        addressLabel.textColor = UIColor.fl_secondary_text
        navigationController?.navigationBar.tintColor = UIColor.fl_secondary_text
        navigationController?.navigationBar.barTintColor = UIColor.fl_accent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }

    private func addBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(onBackButtonPress(_:)))
    }
    
    func onBackButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onVisitButtonTapped(_ sender: UIView) {
        if (user.isAnonymous) {
            let banner = Banner(title: "Login", subtitle: "Please login to mark this location as visited", image: nil, backgroundColor: UIColor.fl_accent!)
            banner.textColor = UIColor.fl_primary_text!
            banner.dismissesOnTap = true
            banner.show(duration: 4.0)
        }
    }

    func onLikeButtonTapped(_ sender: UIView) {
        if (user.isAnonymous) {
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
        addressVisualEffectView.layer.cornerRadius = 20
        addressVisualEffectView.clipsToBounds = true
        
        if let movie = movie {
            if let posterImageURL = movie.posterImageURL {
                posterImageView.setImageWith(posterImageURL)
                miniPosterImage.setImageWith(posterImageURL)
            }
            addressLabel.text = movie.locations[locationIndex].address
            titleLabel.text = "\(movie.title) (\(movie.releaseYear))"
            overviewLabel.text = movie.description
        }
        
        // Anonymous users can't mark as visited or like
        if (user.isAnonymous) {
            visitButton.isUserInteractionEnabled = false
            likeButton.isUserInteractionEnabled = false
        }

        Database.sharedInstance.hasVisitedLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!) { (hasVisited) in
            if (hasVisited) {
                self.visitButton.isSelected = true
            }
        }

        Database.sharedInstance.hasLikedLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!) { (hasLiked) in
            if (hasLiked) {
                self.likeButton.isSelected = true
            }
        }

        updateCounts()
    }

    private func updateCounts() {

        Database.sharedInstance.locationLikesCount(placeId: (movie?.locations[locationIndex].placeId)!) { (count) in
            self.likesCount = count
            self.numberOfLikesLabel.text = String(count)
        }
        Database.sharedInstance.locationVisitsCount(placeId: (movie?.locations[locationIndex].placeId)!) { (count) in
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
        
        self.present(fullscreen, animated: true, completion: nil)
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
        
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func visitLocation(_ sender: UIButton) {
        if visitButton.isSelected {
            Database.sharedInstance.removeVisitLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!, completion: { (completion) in
                self.visitsCount = self.visitsCount - 1
                self.numberOfVisitsLabel.text = String(self.visitsCount)
            })
        } else {
            Database.sharedInstance.visitLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!, completion: { (completion) in
                self.visitsCount = self.visitsCount + 1
                self.numberOfVisitsLabel.text = String(self.visitsCount)
            })
        }
    }

    @IBAction func LikeLocation(_ sender: UIButton) {
        if likeButton.isSelected {
            Database.sharedInstance.removeLikeLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!, completion: { (completion) in
                self.likesCount = self.likesCount - 1
                self.numberOfLikesLabel.text = String(self.likesCount)
            })
        } else {
            Database.sharedInstance.likeLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!, completion: { (completion) in
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
            pvc.postPlaceId = self.movie?.locations[self.locationIndex].placeId

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
        if let images = self.locationImages {
            return images.count
        } else {
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationPhotoCollectionViewCell", for: indexPath) as! LocationPhotoCollectionViewCell
        
        if (locationImages != nil && locationImages.count > 0) {
            Database.sharedInstance.getLocationImage(url: locationImages[indexPath.row].imageURL, completion: { (image) in
                cell.locationPhotoImageView.image = image
            })
        } else {
            Utility.loadFirstPhotoForPlace(placeID: movie!.locations[locationIndex].placeId, callback: { (image) in
                
                if (image != nil) {
                    cell.locationPhotoImageView.image = image
                    self.topBackgroundImageView.image = image
                } else {
                    cell.locationPhotoImageView.image = #imageLiteral(resourceName: "Place-Dummy")
                    self.topBackgroundImageView.image = #imageLiteral(resourceName: "Place-Dummy")
                }
            })
        }
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openFullscreenView(indexPath: indexPath)
    }
}
