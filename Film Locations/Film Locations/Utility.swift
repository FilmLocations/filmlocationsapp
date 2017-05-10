//
//  Utility.swift
//  Film Locations
//
//  Created by Niraj Pendal on 5/9/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import Foundation
import GooglePlaces

class Utility {
    
    class func loadFirstPhotoForPlace(placeID: String, callback: @escaping (UIImage?)->()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
                callback(nil)
            } else {
                
                guard let firstPhoto = photos?.results.first else {
                    callback(nil)
                    return
                }
                GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                    (photo, error) -> Void in
                    if let error = error {
                        // TODO: handle the error.
                        print("Error: \(error.localizedDescription)")
                        callback(nil)
                    } else {
                        callback(photo)
                    }
                })
            }
        }
    }
    
}

