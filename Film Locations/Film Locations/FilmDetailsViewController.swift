//
//  FilmDetailsViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking

class FilmDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var visitLocationButton: UIButton!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var numberOfVisitsLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfUploadsLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            updateUI()
        }
    }
    
    var user: User!
    
    var locationIndex: Int!
    var locationImages: [LocationImage]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        user = User.currentUser

        updateUI()
        
        posterImageView.clipsToBounds = true
        
        let placeId = movie!.locations[locationIndex].placeId
        
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
                
                if (locationImages.count == 1) {
                    self.numberOfUploadsLabel.text = "\(locationImages.count) upload"
                } else {
                    self.numberOfUploadsLabel.text = "\(locationImages.count) uploads"
                }
            }
        }
        
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self

        Database.sharedInstance.locationLikesCount(placeId: (movie?.locations[locationIndex].placeId)!) { (count) in
            if (count > 0) {
                if (count == 1) {
                    self.numberOfLikesLabel.text = "\(count) like"
                } else {
                    self.numberOfLikesLabel.text = "\(count) likes"
                }
            }
        }
        Database.sharedInstance.locationVisitsCount(placeId: (movie?.locations[locationIndex].placeId)!) { (count) in
            if (count > 0) {
                if (count == 1) {
                    self.numberOfVisitsLabel.text = "\(count) visit"
                } else {
                    self.numberOfVisitsLabel.text = "\(count) visits"
                }
            }
        }
        
        //TODO reflect status in the icons
        Database.sharedInstance.hasVisitedLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!) { (hasVisited) in
                print("user has visited \(hasVisited)")
            }
        
        Database.sharedInstance.hasLikedLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!) { (hasLiked) in
                print("user has liked \(hasLiked)")
            }
        
        addBackButton()
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
    
    private func updateUI() {
    
        if viewIfLoaded == nil {
            return
        }

        if let movie = movie {
            if let posterImageURL = movie.posterImageURL {
                posterImageView.setImageWith(posterImageURL)
            }
            addressLabel.text = movie.locations[locationIndex].address
            titleLabel.text = movie.title
            overviewLabel.text = movie.description
        }
        
        // Anonymous users can't mark as visited or like
        if (user.isAnonymous) {
            self.likeButton.isEnabled = false
            self.visitLocationButton.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        print("Visit location")
        Database.sharedInstance.visitLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!)
    }

    @IBAction func LikeLocation(_ sender: UIButton) {
        print("Like location")
        Database.sharedInstance.likeLocation(userId: user.screenname, locationId: (movie?.locations[locationIndex].placeId)!)
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
    
    // TODO - Load google images when we have no user uploaded ones. Prioritize user uploaded images
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let images = self.locationImages {
            return images.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationPhotoCollectionViewCell", for: indexPath) as! LocationPhotoCollectionViewCell
            
        Database.sharedInstance.getLocationImage(url: locationImages[indexPath.row].imageURL, completion: { (image) in
            cell.locationPhotoImageView.image = image
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Fullscreen", bundle: nil)
        
        let fullscreen = storyboard.instantiateViewController(withIdentifier: "Fullscreen") as! FullscreenViewController
        
        fullscreen.locationImageMetadata = locationImages[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! LocationPhotoCollectionViewCell
        fullscreen.locationImage = cell.locationPhotoImageView.image
        
        self.present(fullscreen, animated: true, completion: nil)
    }
    
}
