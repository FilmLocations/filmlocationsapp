//
//  Database.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class Database {
    
    static let sharedInstance = Database()
    
    func getAllFilms(completion: @escaping ([Movie]) -> ()) {
        
        let ref = FIRDatabase.database().reference()
        let films = ref.child("films")
        
        var firebaseMovies = [FirebaseMovie]()
        
        films.observe(.value, with: { (snapshot) in
            
            for child in snapshot.children {
                let data = child as! FIRDataSnapshot
                
                let firebaseMovie = FirebaseMovie(snapshot: data)
                firebaseMovies.append(firebaseMovie)
            }
            
            let movies = self.mapFirebaseMoviesToMovies(firebaseMovies: firebaseMovies)
            completion(movies)
        })
    }
    
    private func mapFirebaseMoviesToMovies(firebaseMovies: [FirebaseMovie]) -> [Movie] {
        var mappedObjects: [String: Movie] = [:]
        var locations: [Location] = []
        var allMovies: [Movie] = []
        
        if !firebaseMovies.isEmpty {
            
            for (_, movie) in firebaseMovies.enumerated() {
                
                // The Movie object is created only in case the data fetched from Firebase is valid
                
                if let _ = movie.id,
                   let title = movie.title,
                   let _ = movie.releaseYear,
                   let _ = movie.posterImageURL,
                   let _ = movie.description,
                   let placeId = movie.placeId,
                   let address = movie.address,
                   let lat = movie.lat,
                   let long = movie.long {

                    if mappedObjects[title] == nil {
                        
                        locations.append(Location(placeId: placeId, address: address, lat: lat, long: long))
                        mappedObjects[title] = Movie(firebaseMovie: movie, locations: locations, isExpanded: false)
                    }
                    else {
                        mappedObjects[title]?.locations.append(Location(placeId: placeId, address: address, lat: lat, long: long))
                    }
                }
            }
        }
        
        for (_, movie) in mappedObjects.enumerated() {
            allMovies.append(movie.value)
        }
        
        return allMovies
    }

    func addPhoto(userId: String, locationId: String, image: UIImage) {
        print("Adding photo for \(userId) to \(locationId)")

        // Get a reference to the storage service using the default Firebase App
        let storage = FIRStorage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        if let data = UIImagePNGRepresentation(image) as Data? {

            let filename = Date().timeIntervalSince1970

            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("photos/\(locationId)/\(filename).jpg")

            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            
            // Upload the file to the path
            imageRef.put(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("Error uploading photo \(error.debugDescription)")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                if let downloadURL = metadata.downloadURL() {
                    print("download url \(downloadURL.absoluteString)")

                    //TODO add to film object for retrieval
                }
            }
        }
    }
    
    func visitLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let visits = ref.child("visits")
        
        visits.child("\(userId)--\(locationId)").setValue(["timestamp": FIRServerValue.timestamp()])
    }
    
    func removeVisitLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let visits = ref.child("visits")

        visits.child("\(userId)--\(locationId)").removeValue()
    }

    func likeLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let likes = ref.child("likes")
        
        likes.child("\(userId)--\(locationId)").setValue(["timestamp": FIRServerValue.timestamp()])
    }
    
    func removeLikeLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let likes = ref.child("likes")

        likes.child("\(userId)--\(locationId)").removeValue()
    }

    func hasVisitedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        let ref = FIRDatabase.database().reference()

        let visit = ref.child("visits/\(userId)--\(locationId)")
        
        visit.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func hasLikedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        let ref = FIRDatabase.database().reference()
        
        let like = ref.child("like/\(userId)--\(locationId)")
        
        like.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
