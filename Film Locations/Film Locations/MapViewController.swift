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

    var scrollingImages:[UIImage]! = []
    @IBOutlet weak var scrollView: UIScrollView!
    var lastUpdatedTimestamp:TimeInterval = 0
    var userCurrentLocation : CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
        
        let image = UIImage(named: "images-4")
        
        for index in 1...5 {
            self.scrollingImages.append(image!)
        }
        
        updateScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateScrollView()  {
        //self.scrollView.delegate = self
        
        self.scrollView.isScrollEnabled = true;
    
        var xOffset:CGFloat = 0
        
        for image in self.scrollingImages {
            let uiImageView = UIImageView(image: image)
            uiImageView.frame = CGRect(x: xOffset, y: 8.0 , width: self.scrollView.frame.height, height: self.scrollView.frame.height)
            self.scrollView.addSubview(uiImageView)
            xOffset = xOffset + self.scrollView.frame.height + 8
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
        
        //for movie in sortedMovies {
            
            //if movie.lat != nil, movie.long != nil {
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = userCurrentLocation //CLLocationCoordinate2D(latitude: movie.lat!, longitude: movie.long!)
                marker.title = "CurrentLocation"//movie.title
                //marker.snippet = movie.
                marker.map = mapView
                
                //loadFirstPhotoForPlace(placeID: self.sortedMovies.first!.placeId!)
            //}
        //}
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentTime = NSDate().timeIntervalSince1970
        if (currentTime - lastUpdatedTimestamp) > 1 * 30 {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            self.userCurrentLocation = locValue
            self.currentLocationUpdated()
            lastUpdatedTimestamp = currentTime
        }
    }
    
}
