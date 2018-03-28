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
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var numberOfVisitsLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var visitLocationView: UIView!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var lyftButton: LyftButton!
    @IBOutlet weak var poweredByGoogleImageView: UIImageView!
    @IBOutlet weak var noPosterImageLabel: UILabel!
    
    var location: FilmLocation! {
        didSet {
            updateUI()
        }
    }
    
    var user: User!
    var locationImages: [LocationImage] = [] {
        didSet {
            photosCollectionView.reloadData()
        }
    }
    var googleAttribution: NSAttributedString?
    
    var visitButton: WCLShineButton!
    var likeButton: WCLShineButton!
    
    var visitsCount = 0 {
        didSet {
            var text = "\(visitsCount) visit"
            
            if visitsCount > 1 || visitsCount == 0 {
                text = "\(text)s"
            }
            numberOfVisitsLabel.text = text
        }
    }
    var likesCount = 0 {
        didSet {
            var text = "\(likesCount) like"

            if likesCount > 1 || likesCount == 0 {
                text = "\(text)s"
            }
            numberOfLikesLabel.text = text
        }
    }
    
    var hasTriedLoadingUserImages = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButtonPress(_:)))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto(_:)))
        
        // Set up action buttons
        var shineParams = WCLShineParams()
        shineParams.bigShineColor = UIColor.fl_accent!
        shineParams.smallShineColor = UIColor.fl_primary!
        
        likeButton = WCLShineButton(frame: .init(x: 5, y: 0, width: 25, height: 25), params: shineParams)
        likeButton.fillColor = UIColor(rgb: (196,23,1))
        likeButton.color = UIColor.fl_primary!
        likeButton.image = .custom(#imageLiteral(resourceName: "heart"))
        likeButton.addTarget(self, action: #selector(LikeLocation(_:)), for: .touchUpInside)
        likesView.addSubview(likeButton)
        
        visitButton = WCLShineButton(frame: .init(x: 5, y: 0, width: 25, height: 25), params: shineParams)
        visitButton.fillColor = UIColor.fl_accent!
        visitButton.color = UIColor.fl_primary!
        visitButton.image = .custom(#imageLiteral(resourceName: "check"))
        visitButton.addTarget(self, action: #selector(visitLocation(_:)), for: .touchUpInside)
        visitLocationView.addSubview(visitButton)
        
        // Do any additional setup after loading the view.
        user = User.currentUser
        
        Database.shared.getLocationImageMetadata(locationId: location.id) { locationImages in
            
            if locationImages.count > 0 {
                Database.shared.getLocationImage(filename: locationImages[0].imageName, completion: { locationImage in
                    self.topBackgroundImageView.image = locationImage
                    self.poweredByGoogleImageView.isHidden = true
                })
                
                self.locationImages = locationImages
                self.photosCollectionView.reloadData()
                self.updateCounts()
                self.hasTriedLoadingUserImages = true
            } else {
                
                Utility.loadFirstPhotoForPlace(placeID: self.location.placeId, callback: { (image, attribution)  in
                    
                    if image != nil {
                        self.topBackgroundImageView.image = image
                        self.googleAttribution = attribution
                        self.photosCollectionView.reloadData()
                    } else {
                        Utility.loadDefaultPhoto(callback: { image in
                            if let image = image {
                                self.topBackgroundImageView.image = image
                                self.photosCollectionView.reloadData()
                            }
                        })
                    }
                })
                
                self.hasTriedLoadingUserImages = true
            }
        }
        
        if let userCurrentLocation = UserDefaults.standard.dictionary(forKey: "kUserCurrentPreferencesKey") {
            let userLocation = CLLocationCoordinate2D(latitude: userCurrentLocation["lat"] as! CLLocationDegrees, longitude: userCurrentLocation["long"] as! CLLocationDegrees)
            
            let destination = CLLocationCoordinate2D(latitude: location.lat, longitude: location.long)
            lyftButton.style = .mulberryDark
            lyftButton.configure(rideKind: LyftSDK.RideKind.Line, pickup: userLocation, destination: destination)
        } else {
            lyftButton.removeFromSuperview()
        }
        
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

        view.backgroundColor = UIColor.white
        likesView.backgroundColor = UIColor.white
        visitLocationView.backgroundColor = UIColor.white
        photosCollectionView.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.fl_primary_light
        overviewTextView.textColor = UIColor.fl_primary_light
        numberOfVisitsLabel.textColor = UIColor.fl_primary_dark
        numberOfLikesLabel.textColor = UIColor.fl_primary_dark
        navigationController?.navigationBar.tintColor = UIColor.fl_primary_text
        navigationController?.navigationBar.barTintColor = UIColor.fl_primary_dark
    }
    
    override func viewDidAppear(_ animated: Bool) {

        Database.shared.getLocationImageMetadata(locationId: location.id) { locationImages in
            
            if locationImages.count > 0 && locationImages.count != self.locationImages.count {
            
                Database.shared.getLocationImage(filename: locationImages[0].imageName, completion: { locationImage in
                    self.topBackgroundImageView.image = locationImage
                })

                self.locationImages = locationImages
                self.photosCollectionView.reloadData()
                self.updateCounts()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // scrolls textview to the top always
        overviewTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
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
        
        if let movie = location {
            if let posterImageURL = movie.posterImageURL {
                posterImageView.setImageWith(posterImageURL)
                noPosterImageLabel.isHidden = true
            }
            addressLabel.text = movie.address
            titleLabel.text = "\(movie.title) (\(movie.releaseYear))"
            overviewTextView.text = movie.description
        }
        
        // Anonymous users can't mark as visited or like
        if user.isAnonymous {
            visitButton.isUserInteractionEnabled = false
            likeButton.isUserInteractionEnabled = false
        } else {
            Database.shared.hasVisitedLocation(userId: user.screenname, locationId: location.id) { hasVisited in
                    self.visitButton.isSelected = hasVisited
            }

            Database.shared.hasLikedLocation(userId: user.screenname, locationId: location.id) { hasLiked in
                    self.likeButton.isSelected = hasLiked
            }
        }

        updateCounts()
        
        likesView.layer.zPosition = 1
        visitLocationView.layer.zPosition = 1
    }

    private func updateCounts() {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            Database.shared.locationLikesCount(locationId: self.location.id) { count in
                self.likesCount = count
            }
            Database.shared.locationVisitsCount(locationId: self.location.id) { count in
                self.visitsCount = count
            }
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
            if (locationImages.count > 0) {
                fullscreen.locationImageMetadata = locationImages[indexPath.row]
            }
            
            let cell = photosCollectionView.cellForItem(at: indexPath as IndexPath) as! LocationPhotoCollectionViewCell
            fullscreen.locationImage = cell.locationPhotoImageView.image
        } else {
            if (locationImages.count > 0) {
                fullscreen.locationImageMetadata = locationImages[0]
            }
            fullscreen.locationImage = topBackgroundImageView.image
        }
        
        fullscreen.googleAttribution = googleAttribution

        present(fullscreen, animated: true, completion: nil)
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        
        guard !user.isAnonymous else {
            let banner = Banner(title: "Login", subtitle: "Please login to contribute a photo of this location", image: nil, backgroundColor: UIColor.fl_accent!)
            banner.textColor = UIColor.fl_primary_text!
            banner.dismissesOnTap = true
            banner.show(duration: 4.0)
            return
        }
        
        let photoChooserAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        photoChooserAlert.view.tintColor = UIColor.fl_secondary
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            photoChooserAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
                self.choosePhoto(sourceType: .camera)
            }))
        }
        
        photoChooserAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.choosePhoto(sourceType: .photoLibrary)
        }))
        
        photoChooserAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(photoChooserAlert, animated: true)
    }
    
    func choosePhoto(sourceType: UIImagePickerControllerSourceType) {
        let vc = UIImagePickerController()
        vc.navigationBar.barTintColor = UIColor.fl_primary
        vc.navigationBar.tintColor = UIColor.white
        vc.navigationBar.isTranslucent = false
        vc.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = sourceType
        
        present(vc, animated: true, completion: nil)
    }

    @IBAction func visitLocation(_ sender: UIButton) {
        if visitButton.isSelected {
            Database.shared.removeVisitLocation(userId: user.screenname, locationId: location.id, completion: { completion in
                self.visitsCount = self.visitsCount - 1
            })
        } else {
            Database.shared.visitLocation(userId: user.screenname, locationId: location.id, completion: { completion in
                self.visitsCount = self.visitsCount + 1
            })
        }
    }

    @IBAction func LikeLocation(_ sender: UIButton) {
        if likeButton.isSelected {
            Database.shared.removeLikeLocation(userId: user.screenname, locationId: location.id, completion: { completion in
                self.likesCount = self.likesCount - 1
            })
        } else {
            Database.shared.likeLocation(userId: user.screenname, locationId: location.id, completion: { completion in
                self.likesCount = self.likesCount + 1
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
            pvc.locationId = self.location.id
            
            
            let navigationController = UINavigationController(rootViewController: pvc)
            navigationController.setViewControllers([pvc], animated: false)
            
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

extension FilmDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if locationImages.count > 0 {
            return locationImages.count
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
        
        if (locationImages.count > 0) {
            poweredByGoogleImageView.isHidden = true
            
            Database.shared.getLocationImage(filename: locationImages[indexPath.row].imageName, completion: { image in
                cell.locationPhotoImageView.image = image
            })
        } else {
            if let image = topBackgroundImageView.image {
                cell.locationPhotoImageView.image = image
            }
        }
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openFullscreenView(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (view.frame.width / 3) - 1, height: (view.frame.width / 3) - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
}
