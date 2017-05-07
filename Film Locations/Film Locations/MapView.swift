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
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)

        mapView.delegate = self
        
        self.googleMapView = mapView
        self.googleMapView.isMyLocationEnabled = true
        
        self.addSubview(self.googleMapView)
    }
    
    override func layoutSubviews() {
     
        googleMapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        print("layOut subviews")
        
    }
    
    func updateMapsMarkers(sortedMovies:[MapMovie]) {
        
        self.displayData = sortedMovies
        
        self.googleMapView.clear()
        
        var bounds = GMSCoordinateBounds()
        
        for movie in sortedMovies {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: movie.location.lat, longitude: movie.location.long)
            marker.title = movie.title
            print(movie.title, movie.location.lat, movie.location.long, movie.location.address)
            marker.isFlat = true
            marker.userData = movie
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = self.googleMapView
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        self.googleMapView.animate(with: update)
    }
}

extension MapView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let markerMovie = marker.userData as? MapMovie {
            
            if let index = self.displayData.index(where: {$0.location.placeId ==  markerMovie.location.placeId }){
                delegate?.didTap(markerIndex: index)
            }
        }
        
        return true
    }
}
