//
//  MapViewController.swift
//  Film Locations
//
//  Created by Niraj Pendal on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import CoreLocation

class MapViewController: UIViewController, MenuContentViewControllerProtocol {
    
    let maxNearByMovies = 40
    let currentUsersLocationKey =  "kUserCurrentPreferncesKey"
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var carousel: iCarousel!
    
    var scrollingImages:[UIImage]! = []
    var lastUpdatedTimestamp: TimeInterval = 0
    var userCurrentLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let locationManager = CLLocationManager()
    
    var posterImageViewBottomConstraint: NSLayoutConstraint!
    var posterImageViewBottomConstraintConstantPadding: CGFloat = 20.0
    
    var isSearchResultsDisplayed = false
    
    var locations: [FilmLocation]!
    var sortedMovies:[FilmLocation]!
    
    let activityIndicator = ActivityIndicator()
    let searchBar = UISearchBar()
    
    var delegate: MenuButtonPressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carousel.type = .coverFlow2
        carousel.delegate = self
        carousel.dataSource = self
        carousel.setNeedsLayout()
        
        posterImageViewBottomConstraint = carousel.topAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor, constant: posterImageViewBottomConstraintConstantPadding)
        view.addConstraint(posterImageViewBottomConstraint)
        
        presentIndicator()
        
        Database.sharedInstance.getAllLocations { locations in
            self.locations = locations
            
            // Request location when in use only
            self.locationManager.requestWhenInUseAuthorization()
            
            if let currentLocation =  self.retrieveCurrentLocation() {
                self.userCurrentLocation = currentLocation
            }
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.startUpdatingLocation()
            }
            
            self.mapView.delegate = self

            self.hideIndicator()
        }
        
        // Add searchbar to navigation
        searchBar.placeholder = "Search Films"
        searchBar.sizeToFit()
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    func presentIndicator()  {
        activityIndicator.showActivityIndicator(uiView: (navigationController?.view)!)
    }
    
    func hideIndicator()  {
        activityIndicator.hideActivityIndicator(view: (navigationController?.view)!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        delegate?.onMenuButtonPress()
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
        print("User locations = \(userCurrentLocation.latitude) \(userCurrentLocation.longitude)")
        
        sortedMovies = sortMoviesFromUserLocation(moviesToSort: locations)
        updateViewWithNewData()
    }
    
    func updateViewWithNewData() {
        //TODO: consider calling map marker and scroll view in a single for loop
        mapView.updateMapsMarkers(sortedMovies: sortedMovies)
        carousel.reloadData()
        //self.updateScrollView(isSearchedData: false)
    }
    
    func updateViewWithSearchData() {
        //TODO: consider calling map marker and scroll view in a single for loop
        mapView.updateMapsMarkers(sortedMovies: sortedMovies)
        carousel.reloadData()
        //self.updateScrollView(isSearchedData: true)
    }
    
    // TODO: Move this method to API class as utility method
    func sortMoviesFromUserLocation(moviesToSort: [FilmLocation]) -> [FilmLocation] {
        
        let sortedMovies = moviesToSort.sorted { (movie1:FilmLocation, movie2:FilmLocation) -> Bool in
            
            let currentLocation = CLLocation(latitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude)
            
            let location1 = CLLocation(latitude: movie1.lat, longitude: movie1.long)
            let location2 = CLLocation(latitude: movie2.lat, longitude: movie2.long)
            
            let difference1 =  currentLocation.distance(from: location1)
            let difference2 = currentLocation.distance(from: location2)
            
            return difference1 < difference2
        }
        
        let toIndex = sortedMovies.count < maxNearByMovies ? sortedMovies.count : maxNearByMovies
        
        return Array(sortedMovies[0..<toIndex])
    }
}

extension MapViewController: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        if sortedMovies != nil {
            return sortedMovies.count
        } else {
            return 0
        }
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let userLocation = CLLocation(latitude: userCurrentLocation.latitude, longitude: userCurrentLocation.longitude)
        
        let moviePosterViewDataSource = MoviePosterViewDataSource(location: sortedMovies[index], displaySearchData: isSearchResultsDisplayed, referenceLocation: userLocation)
        
        let moviePosterView = MoviePosterView(frame: CGRect(x: 8.0, y: 8.0 , width: carousel.bounds.height+80, height: carousel.bounds.height))
        moviePosterView.moviePosterDataSource = moviePosterViewDataSource
        moviePosterView.delegate = self
        
        return moviePosterView
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if posterImageViewBottomConstraint.constant != posterImageViewBottomConstraintConstantPadding {
            mapView.selectMarker(index: carousel.currentItemIndex)
        }
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        mapView.selectMarker(index: index)
    }
}

extension MapViewController: MapViewDelegate {
    
    func didTapOnMap() {
        searchBar.resignFirstResponder()
        
        if self.posterImageViewBottomConstraint.constant != posterImageViewBottomConstraintConstantPadding {
            hidePosterImageView()
        }
    }
    
    func didTap(markerIndex: Int) {
        if posterImageViewBottomConstraint.constant == posterImageViewBottomConstraintConstantPadding {
            showPosterImageView(markerIndex: markerIndex)
        } else {
            carousel.scrollToItem(at: markerIndex, animated: false)
        }
    }
    
    func hidePosterImageView() {
        posterImageViewBottomConstraint.constant = posterImageViewBottomConstraintConstantPadding
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showPosterImageView(markerIndex: Int) {
        posterImageViewBottomConstraint.constant = -1 * carousel.bounds.height
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { success in
            if success {
                self.carousel.scrollToItem(at: markerIndex, animated: false)
            }
        })
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentTime = NSDate().timeIntervalSince1970
        if ((currentTime - lastUpdatedTimestamp) > 1 * 30) && !isSearchResultsDisplayed && ((userCurrentLocation.latitude != manager.location!.coordinate.latitude) || (userCurrentLocation.longitude != manager.location!.coordinate.longitude)) {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            userCurrentLocation = locValue

            currentLocationUpdated()
            lastUpdatedTimestamp = currentTime
            manager.stopUpdatingLocation()
        }
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearchResultsDisplayed = false
        currentLocationUpdated()
        searchBar.resignFirstResponder()        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let query = searchBar.text {
            
            if query.count > 0 {
                let filteredMovies = locations.filter { movie -> Bool in
                    
                    if (movie.title.lowercased().range(of:query.lowercased()) != nil) || (movie.releaseYear.lowercased().range(of: query.lowercased()) != nil) {
                        return true
                    }
                    return false
                }
                
                sortedMovies = sortMoviesFromUserLocation(moviesToSort: filteredMovies)
                
                updateViewWithSearchData()
                isSearchResultsDisplayed = true
            }
        } else {
            isSearchResultsDisplayed = false
        }
    }
}

extension MapViewController: MoviePosterViewDelegate {
    
    func didTapOnImage(selectedLocation: FilmLocation) {
        
        let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)
        
        if let detailsViewController = filmDetailsStoryBoard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController {
            
            detailsViewController.location = selectedLocation
            
            let navigationController = UINavigationController(rootViewController: detailsViewController)
            navigationController.setViewControllers([detailsViewController], animated: false)
            
            present(navigationController, animated: true, completion: nil)
        }
    }
}
