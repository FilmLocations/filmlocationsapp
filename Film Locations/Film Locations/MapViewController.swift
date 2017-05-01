//
//  MapViewController.swift
//  Film Locations
//
//  Created by Niraj Pendal on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    let maxNearByMovies = 20
    let currentUsersLocationKey =  "kUserCurrentPreferncesKey"
    
    var scrollingImages:[UIImage]! = []
    @IBOutlet weak var scrollView: UIScrollView!
    var lastUpdatedTimestamp:TimeInterval = 0
    var userCurrentLocation : CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: UIView!
    var googleMapView: GMSMapView!
    
    var movies: [Movie]!
    var sortedMovies:[Movie]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.userCurrentLocation = retrieveCurrentLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
        
        
        
//        let image = UIImage(named: "images-4")
//        
//        for index in 1...5 {
//            self.scrollingImages.append(image!)
//        }
        
        //updateScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveUsersLastKnownLocation(userCurrentLocation: CLLocationCoordinate2D) {
        UserDefaults.standard.set(["lat": userCurrentLocation.latitude, "long": userCurrentLocation.longitude], forKey: currentUsersLocationKey)
        UserDefaults.standard.synchronize()
    }
    
    func retrieveCurrentLocation() -> CLLocationCoordinate2D? {
        if let userCurrentLocation = UserDefaults.standard.dictionary(forKey: currentUsersLocationKey) {
            let userLocation = CLLocationCoordinate2D(latitude: userCurrentLocation["lat"] as! CLLocationDegrees, longitude: userCurrentLocation["long"] as! CLLocationDegrees)
            return userLocation
        }
        
        return nil
    }
    
    func updateScrollView()  {
        //self.scrollView.delegate = self
        
        self.scrollView.isScrollEnabled = true;
        
        var xOffset:CGFloat = 0
        
        for movie in self.sortedMovies {
            
            if let posteImageView = movie.posterImageURL {
                
                let moviePosterView = MoviewPosterView(frame: CGRect(x: xOffset, y: 8.0 , width: self.scrollView.frame.height, height: self.scrollView.frame.height))
                moviePosterView.movie = movie
                self.scrollView.addSubview(moviePosterView)
                xOffset = xOffset + self.scrollView.frame.height + 8
            }
        }
        self.scrollView.contentSize =  CGSize(width: xOffset, height: self.scrollView.frame.height)
        //
        //        scrollVie.contentSize = CGSizeMake(scrollWidth+xOffset,110);
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func currentLocationUpdated() {
        // Update map view
        print("Uesr locations = \(userCurrentLocation.latitude) \(userCurrentLocation.longitude)")
        
        let userLat = userCurrentLocation.latitude
        let userLong = userCurrentLocation.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: userLat, longitude: userLong, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.frame = CGRect(x:0, y:0, width:self.mapView.frame.width, height:self.mapView.frame.height)
        //self.mapView = mapView
        self.mapView.addSubview(mapView)
        
        Database.getAllFilms { (movies:[Movie]) in
            self.movies = movies
            self.sortMoviesFromUserLocation()
            
            for movie in self.sortedMovies {
                
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: (movie.locations.first?.lat)!, longitude: (movie.locations.first?.long)!)
                marker.title = movie.title
                marker.map = mapView
                
            }
            
            self.updateScrollView()
        }
    }
    
    func sortMoviesFromUserLocation() {
        
        let filteredMovies = self.movies.filter { (movie: Movie) -> Bool in
            if movie.locations.first?.lat != nil, movie.locations.first?.long != nil{
                return true
            }
            return false
        }
        
        let sortedMovies = filteredMovies.sorted { (movie1:Movie, movie2:Movie) -> Bool in
            
            let currentLocation = CLLocation(latitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude)
            
            let location1 = CLLocation(latitude: (movie1.locations.first?.lat)!, longitude: (movie1.locations.first?.long)!)
            let location2 = CLLocation(latitude: (movie2.locations.first?.lat)!, longitude: (movie2.locations.first?.long)!)
            
            let differnce1 =  currentLocation.distance(from: location1)
            let differnce2 = currentLocation.distance(from: location2)
            
            return differnce1 < differnce2
        }
        
        self.sortedMovies = Array(sortedMovies[0..<maxNearByMovies])
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentTime = NSDate().timeIntervalSince1970
        if (currentTime - lastUpdatedTimestamp) > 1 * 30 {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            self.userCurrentLocation = locValue
            
            //remove this line
            self.userCurrentLocation = CLLocationCoordinate2D (latitude: 37.7881968, longitude: -122.3960219)
            self.currentLocationUpdated()
            lastUpdatedTimestamp = currentTime
        }
    }
    
}
