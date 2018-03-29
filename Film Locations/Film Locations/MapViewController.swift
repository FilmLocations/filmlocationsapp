//
//  MapViewController.swift
//  Film Locations
//
//  Created by Niraj Pendal on 4/29/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import CoreLocation
import NVActivityIndicatorView

class MapViewController: UIViewController, MenuContentViewControllerProtocol {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var carouselBottomConstraint: NSLayoutConstraint!
    
    let maxNearbyMovies = 35
    let currentUsersLocationKey =  "kUserCurrentPreferencesKey"
    
    var scrollingImages:[UIImage]! = []
    var lastUpdatedTimestamp: TimeInterval = 0
    var userCurrentLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var isSearchResultsDisplayed = false
    
    var locations = [FilmLocation]()
    var sortedLocations = [FilmLocation]()

    let searchBar = UISearchBar()
    
    var delegate: MenuButtonPressDelegate?
    var currentMarkerIndex = 0
    
    var viewingMapLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let sfCenter = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    var safeAreaOffset: CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    var sfRegion: CLCircularRegion {
        let approximate7MileRadius = CLLocationDistance(exactly: 11300)
        return CLCircularRegion(center: sfCenter, radius: approximate7MileRadius!, identifier: "SF")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request location when in use only
        locationManager.requestWhenInUseAuthorization()
        
        if let currentLocation = retrieveCurrentLocation() {
            if sfRegion.contains(currentLocation) {
                userCurrentLocation = currentLocation
                mapView.updatePhysicalLocation(location: currentLocation)
            } else {
                mapView.updatePhysicalLocation(location: sfCenter)
            }
        } else {
            viewingMapLocation = sfCenter
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
        
        activityIndicatorView.type = NVActivityIndicatorType.ballScaleMultiple
        activityIndicatorView.color = UIColor.fl_secondary!
        
        presentIndicator()
        Database.shared.getAllLocations { locations in
            self.locations = locations
            
            self.mapView.delegate = self
            
            self.carousel.type = .coverFlow2
            self.carousel.delegate = self
            self.carousel.dataSource = self
            self.carousel.setNeedsLayout()
            
            self.currentLocationUpdated()
            
            self.hideIndicator()
        }
        
        // Add searchbar to navigation
        searchBar.placeholder = "Search Films"
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.keyboardAppearance = .dark
        searchBar.tintColor = UIColor.fl_secondary
        navigationItem.titleView = searchBar
    }
    
    func presentIndicator() {
        activityIndicatorView.startAnimating()
    }
    
    func hideIndicator() {
        activityIndicatorView.stopAnimating()
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
        guard locations.count > 0 else {
            return
        }
        
        sortedLocations = sortMoviesFromUserLocation(moviesToSort: locations, at: viewingMapLocation)
        updateViewWithNewData()
    }
    
    func updateViewWithNewData() {
        // When searching - do not update the view
        if (!isSearchResultsDisplayed) {
            mapView.updateMapsMarkers(sortedLocations: sortedLocations)
            carousel.reloadData()
        }
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
        return sortedLocations.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        var userLocation: CLLocation? = nil
        
        if userCurrentLocation != nil {
            userLocation = CLLocation(latitude: userCurrentLocation!.latitude, longitude: userCurrentLocation!.longitude)
        }
        
        let moviePosterViewDataSource = MoviePosterViewDataSource(location: sortedLocations[index], displaySearchData: isSearchResultsDisplayed, currentUserLocation: userLocation)
        
        let moviePosterView = MoviePosterView(frame: CGRect(x: 8.0, y: 8.0 , width: carousel.bounds.width-50, height: carousel.bounds.height))
        moviePosterView.moviePosterDataSource = moviePosterViewDataSource
        moviePosterView.delegate = self
        
        return moviePosterView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        currentMarkerIndex = carousel.currentItemIndex
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if (carouselBottomConstraint.constant == 0 + safeAreaOffset) {
            mapView.selectMarker(index: currentMarkerIndex)
        }
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        mapView.selectMarker(index: index)
    }
}

extension MapViewController: MapViewDelegate {
    
    func didMoveInMap(newLocation: CLLocationCoordinate2D) {
        viewingMapLocation = newLocation
        
        // When searching - do not update the view
        if (!isSearchResultsDisplayed) {
            sortedLocations = sortMoviesFromUserLocation(moviesToSort: locations, at: newLocation)
            updateViewWithNewData()
        }
    }
    
    func didTapOnMap() {
        searchBar.resignFirstResponder()
        
        if (delegate?.isSideMenuOpen() ?? false) {
            delegate?.onMenuButtonPress()
            return
        }
        
        if carouselBottomConstraint.constant >= 0 {
            hidePosterImageView()
        }
    }
    
    
    func didTapMarker(markerIndex: Int) {
        currentMarkerIndex = markerIndex
        showPosterImageView(markerIndex: markerIndex)
    }
    
    func hidePosterImageView() {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            self.carouselBottomConstraint.constant = -1 * (self.carousel.bounds.height + self.safeAreaOffset)
            self.view.layoutIfNeeded()
        })
    }
    
    func showPosterImageView(markerIndex: Int) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            
            self.carouselBottomConstraint.constant = 0 + self.safeAreaOffset
            self.view.layoutIfNeeded()
        }, completion: { success in
            if success {
                self.currentMarkerIndex = markerIndex
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
            
            if sfRegion.contains(userCurrentLocation!) {
                mapView.updatePhysicalLocation(location: locValue)
            } else {
                mapView.updatePhysicalLocation(location: sfCenter)
            }

            saveUsersLastKnownLocation(userCurrentLocation: locValue)

            currentLocationUpdated()
            lastUpdatedTimestamp = currentTime
            manager.stopUpdatingLocation()
        }
    }
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.placeholder = ""
        
        guard delegate?.isSideMenuOpen() == false else {
            delegate?.onMenuButtonPress()
            return true
        }
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search Films"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {
            return
        }
        
        if text.isEmpty {
            isSearchResultsDisplayed = false
            currentLocationUpdated()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearchResultsDisplayed = false
        searchBar.resignFirstResponder()
        
        if let query = searchBar.text {
            
            if query.count > 0 {
                let filteredMovies = locations.filter { movie -> Bool in
                    
                    if (movie.title.lowercased().range(of:query.lowercased()) != nil) || (String(movie.releaseYear).range(of: query.lowercased()) != nil) {
                        return true
                    }
                    return false
                }
                
                sortedLocations = sortMoviesFromUserLocation(moviesToSort: filteredMovies, at: viewingMapLocation)
                
                updateViewWithNewData()
                mapView.selectMarker(index: 0)

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
