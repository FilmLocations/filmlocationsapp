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
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var carousel: iCarousel!
    
    let maxNearbyMovies = 45
    let currentUsersLocationKey =  "kUserCurrentPreferencesKey"
    
    var scrollingImages:[UIImage]! = []
    var lastUpdatedTimestamp: TimeInterval = 0
    var userCurrentLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var posterImageViewBottomConstraint: NSLayoutConstraint!
    var posterImageViewBottomConstraintConstantPadding: CGFloat = 20.0
    
    var isSearchResultsDisplayed = false
    
    var locations: [FilmLocation]!
    var sortedLocations:[FilmLocation]!
    
    let activityIndicator = ActivityIndicator()
    let searchBar = UISearchBar()
    
    var delegate: MenuButtonPressDelegate?
    
    var viewingMapLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentIndicator()
        
        Database.sharedInstance.getAllLocations { locations in
            self.locations = locations
            
            // Request location when in use only
            self.locationManager.requestWhenInUseAuthorization()
            
            if let currentLocation =  self.retrieveCurrentLocation() {
                self.userCurrentLocation = currentLocation
                self.viewingMapLocation = currentLocation
            } else {
                self.viewingMapLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            }
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.startUpdatingLocation()
            }
            
            self.mapView.delegate = self
            
            self.carousel.type = .coverFlow2
            self.carousel.delegate = self
            self.carousel.dataSource = self
            self.carousel.setNeedsLayout()
            
            self.posterImageViewBottomConstraint = self.carousel.topAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor, constant: self.posterImageViewBottomConstraintConstantPadding)
            self.view.addConstraint(self.posterImageViewBottomConstraint)
            
            self.hideIndicator()
        }
        
        // Add searchbar to navigation
        searchBar.placeholder = "Search Films"
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
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

    func currentLocationUpdated() {
        sortedLocations = sortMoviesFromUserLocation(moviesToSort: locations, at: userCurrentLocation ?? viewingMapLocation)
        updateViewWithNewData()
    }
    
    func updateViewWithNewData() {
        mapView.updateMapsMarkers(sortedLocations: sortedLocations)
        carousel.reloadData()
    }
    
    func sortMoviesFromUserLocation(moviesToSort: [FilmLocation], at location: CLLocationCoordinate2D) -> [FilmLocation] {
        
        let sortedMovies = moviesToSort.sorted { (movie1:FilmLocation, movie2:FilmLocation) -> Bool in
            
            let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let location1 = CLLocation(latitude: movie1.lat, longitude: movie1.long)
            let location2 = CLLocation(latitude: movie2.lat, longitude: movie2.long)
            
            let difference1 =  currentLocation.distance(from: location1)
            let difference2 = currentLocation.distance(from: location2)
            
            return difference1 < difference2
        }
        
        let toIndex = sortedMovies.count < maxNearbyMovies ? sortedMovies.count : maxNearbyMovies
        
        return Array(sortedMovies[0..<toIndex])
    }
}

extension MapViewController: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        if sortedLocations != nil {
            return sortedLocations.count
        } else {
            return 0
        }
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let userLocation: CLLocation? = CLLocation(latitude: userCurrentLocation!.latitude, longitude: userCurrentLocation!.longitude)
        
        let moviePosterViewDataSource = MoviePosterViewDataSource(location: sortedLocations[index], displaySearchData: isSearchResultsDisplayed, currentUserLocation: userLocation)
        
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
    
    func didMoveInMap(newLocation: CLLocationCoordinate2D) {
        viewingMapLocation = newLocation
        sortedLocations = sortMoviesFromUserLocation(moviesToSort: locations, at: newLocation)
        updateViewWithNewData()
    }
    
    func didTapOnMap() {
        searchBar.resignFirstResponder()
        
        if (delegate?.isSideMenuOpen() ?? false) {
            delegate?.onMenuButtonPress()
            return
        }
        
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
        if ((currentTime - lastUpdatedTimestamp) > 1 * 30) && !isSearchResultsDisplayed {
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
                
                sortedLocations = sortMoviesFromUserLocation(moviesToSort: filteredMovies, at: viewingMapLocation)
                
                updateViewWithNewData()
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
