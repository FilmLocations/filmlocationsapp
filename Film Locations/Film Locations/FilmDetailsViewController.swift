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
    
    ///** Sample testing data, pass film object later
    let address = "Jones and Pacific"
    // test reading from firebase, not working yet
    let backgroundURL = "https://firebasestorage.googleapis.com/v0/b/filmlocations-78a31.appspot.com/o/photos%2FtestLocation%2F1493538405.55338.jpg"

    
    /////
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var visitLocationButton: UIButton!
    
    var movie: Movie? {
        didSet {
            updateUI()
        }
    }
    
    var locationIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        updateUI()
        
        posterImageView.clipsToBounds = true

        if let backgroundImageURL = URL(string: backgroundURL) {
            topBackgroundImageView.setImageWith(backgroundImageURL)
        }
        
//        addressLabel.text = address
        
        photosCollectionView.dataSource = self

        // TODO Set movie during the segue to this view and get the id from there
//        Database.sharedInstance.getFilm(filmId: 65050) { (movie) in
//            self.movie = movie

//            print("got a movie")
//            print(movie.title)
//            print(movie.locations)
//            print(movie.releaseYear)
//            print(movie.posterImageURL?.absoluteString ?? "")
//            if let posterImageURL = movie.posterImageURL {
//                self.posterImageView.setImageWith(posterImageURL)
//            }
//            self.titleLabel.text = "\(movie.title) (\(movie.releaseYear))"

            //TODO Send real user data, reflect status in the icons
//            Database.hasVisitedLocation(userId: "testUser1", locationId: self.movie.locations[0].placeId) { (hasVisited) in
//                print("user has visited \(hasVisited)")
//            }
//            Database.hasLikedLocation(userId: "testUser1", locationId: self.movie.locations[0].placeId) { (hasVisited) in
//                print("user has liked \(hasVisited)")
//            }
//        }
        
        addBackButton()
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        print("Add photo")
      
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
//        Database.visitLocation(userId: "testUser1", locationId: self.movie.locations[0].placeId)
    }

    @IBAction func LikeLocation(_ sender: UIButton) {
        print("Like location")
//        Database.likeLocation(userId: "testUser1", locationId: self.movie.locations[0].placeId)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        Database.sharedInstance.addPhoto(userId: "testUser", locationId: "testLocation", image: editedImage)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        
        // TODO go to post view controller 
        
        dismiss(animated: true, completion: nil)
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

extension FilmDetailsViewController: UICollectionViewDataSource {
    // TODO - Getting the photos, prioritize by user uploads and then google images?
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationPhotoCollectionViewCell", for: indexPath) as! LocationPhotoCollectionViewCell

        return cell
    }
}
