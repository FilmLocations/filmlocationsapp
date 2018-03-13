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
    
    class func loadRandomPhotoForPlace(placeID: String, callback: @escaping (UIImage?)->()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
                callback(nil)
            } else {
                
                if let count = photos?.results.count {
                    let randomNum:Int = Int(arc4random_uniform(UInt32(count-1)))
                    guard let photo = photos?.results[randomNum] else {
                        //print("Error: \(error.localizedDescription)")
                        callback(nil)
                        return
                    }
                    
                    GMSPlacesClient.shared().loadPlacePhoto(photo, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            // TODO: handle the error.
                            print("Error: \(error.localizedDescription)")
                            callback(nil)
                        } else {
                            callback(photo)
                        }
                    })
                    
                } else {
                    callback(nil)
                    return
                }
            }
        }
    }
    
    class func loadFirstPhotoForPlace(placeID: String, callback: @escaping (UIImage?, NSAttributedString?)->()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
                callback(nil, nil)
            } else {
                
                guard let firstPhoto = photos?.results.first else {
                    callback(nil, nil)
                    return
                }

                GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                    (photo, error) -> Void in
                    if let error = error {
                        // TODO: handle the error.
                        print("Error: \(error.localizedDescription)")
                        callback(nil, nil)
                    } else {
                        callback(photo, firstPhoto.attributions)
                    }
                })
            }
        }
    }
}
