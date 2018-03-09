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
    func didMoveInMap(newLocation: CLLocationCoordinate2D)
}

class MapView: UIView {
    var displayData: [FilmLocation]!
    var googleMapView: GMSMapView!
    weak var delegate: MapViewDelegate?
    var currentSelectedMarker: GMSMarker?
    var markers = [GMSMarker]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadInitialMap()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadInitialMap()
    }
    
    private func loadInitialMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.7749, longitude: -122.4194, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }

        googleMapView = mapView
        googleMapView.isMyLocationEnabled = true
        googleMapView.settings.myLocationButton = true
        
        addSubview(googleMapView)
    }
    
    override func layoutSubviews() {
        googleMapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func viewDidDisappear() {
        googleMapView.selectedMarker = nil
    }
    
    func updatePhysicalLocation(location: CLLocationCoordinate2D) {
        googleMapView.animate(toLocation: location)
    }
    
    func updateMapsMarkers(sortedLocations: [FilmLocation]) {
        
        displayData = sortedLocations

        currentSelectedMarker = nil
        googleMapView.clear()
        
        var bounds = GMSCoordinateBounds()
        
        for movie in sortedLocations {
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: movie.lat, longitude: movie.long)
            marker.title = movie.title
            marker.snippet = movie.address
            marker.isFlat = true
            marker.userData = movie
            marker.icon = UIImage(named: "Location-Marker")
            bounds = bounds.includingCoordinate(marker.position)
            marker.map = googleMapView
            
            markers.append(marker)
        }
    }
    
    func selectMarker(index: Int)  {
        let marker = markers[index]
        
        selectMarker(marker: marker)
    }
    
    func unSelectMarker()  {
       
        guard let selectedMarker = currentSelectedMarker else {
            return
        }

        selectedMarker.icon = UIImage(named: "Location-Marker")
        currentSelectedMarker = nil
        googleMapView.selectedMarker = nil
    }
    
    func selectMarker(marker: GMSMarker)  {
        
        unSelectMarker()
        
        if let markerMovie = marker.userData as? FilmLocation {
            
            if let index = displayData.index(where: {$0.placeId == markerMovie.placeId && $0.tmdbId ==  markerMovie.tmdbId}) {
                delegate?.didTap(markerIndex: index)
                currentSelectedMarker = marker
            }
        }
        
        googleMapView.selectedMarker = marker
        
        marker.icon = UIImage(named: "Selected-Marker")
    }
}

extension MapView: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        delegate?.didMoveInMap(newLocation: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        delegate?.didTapOnMap()
        unSelectMarker()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if mapView.selectedMarker == marker {
            return true
        }
        
        selectMarker(marker: marker)
        
        return true
    }
}
