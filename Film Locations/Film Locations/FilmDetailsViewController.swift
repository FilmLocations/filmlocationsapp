//
//  FilmDetailsViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking

class FilmDetailsViewController: UIViewController {
    
    ///** Sample testing data, pass film object later
    let filmTitle = "Blue Jasmine (2013)"
    let address = "Jones and Pacific"
    let posterImageViewURL = "http://image.tmdb.org/t/p/w185//tXzOAeub5ZaxGv9vkJLtU0aNenl.jpg"
    
    /////
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var topBackgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var visitLocationButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        posterImageView.clipsToBounds = true
        if let posterImageURL = URL(string: posterImageViewURL) {
            posterImageView.setImageWith(posterImageURL)
        }
        
        titleLabel.text = filmTitle
        addressLabel.text = address
        
        photosCollectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        print("Add photo")
    }

    @IBAction func visitLocation(_ sender: UIButton) {
        print("Visit location")
    }

    @IBAction func LikeLocation(_ sender: UIButton) {
        print("Like location")
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationPhotoCollectionViewCell", for: indexPath) as! LocationPhotoCollectionViewCell

        return cell
    }
}
