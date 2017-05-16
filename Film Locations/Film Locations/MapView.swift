//
//  MapView.swift
//  Film Locations
//
//  Created by Niraj Pendal on 5/2/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol MapViewDelegate: class {
    func didTap(markerIndex: Int)
    func didTapOnMap()
}

class MapView: UIView {
    var displayData:[MapMovie]!
    var googleMapView: GMSMapView!
    weak var delegate:MapViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadInitialMap()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadInitialMap()
    }
    
    
    
    private func loadInitialMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        self.googleMapView = mapView
        self.googleMapView.isMyLocationEnabled = true
        self.addSubview(self.googleMapView)
    }
    
    override func layoutSubviews() {
        googleMapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func viewDidDisappear() {
        googleMapView.selectedMarker = nil
    }
    
    func updateMapsMarkers(sortedMovies:[MapMovie]) {
        
        //if googleMapView.selectedMarker == nil {
            
            self.displayData = sortedMovies
            
            self.googleMapView.clear()
            
            var bounds = GMSCoordinateBounds()
            
            for movie in sortedMovies {
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: movie.location.lat, longitude: movie.location.long)
                marker.title = movie.title
                marker.snippet = movie.location.address
                //print(movie.title, movie.location.lat, movie.location.long, movie.location.address)
                marker.isFlat = true
                marker.userData = movie
                marker.icon = UIImage(named: "Location-Marker-48")
                bounds = bounds.includingCoordinate(marker.position)
                marker.map = self.googleMapView
            }
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 20)
            self.googleMapView.animate(with: update)
       // }
    }
}

extension MapView: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        delegate?.didTapOnMap()
        mapView.selectedMarker = nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let markerMovie = marker.userData as? MapMovie {
            
            if let index = self.displayData.index(where: {$0.location.placeId ==  markerMovie.location.placeId }){
                delegate?.didTap(markerIndex: index)
            }
        }
        
        if let selectedMarker = mapView.selectedMarker {
            //selectedMarker.icon = UIImage(named: "Location-Marker-48")
        }
        
        if mapView.selectedMarker == marker {
            mapView.selectedMarker = nil
            return true
        }
        
        mapView.selectedMarker = marker
        //marker.icon = UIImage(named: "SelectedMarker-1")
        return true
    }
}
