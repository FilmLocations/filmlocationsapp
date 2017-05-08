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
                        locations.removeAll()
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

    func addPhoto(userId: String, placeId: String, image: UIImage, description: String, completion: @escaping (Bool) -> ()) {
        print("Adding photo for \(userId) to \(placeId)")

        // Get a reference to the storage service using the default Firebase App
        let storage = FIRStorage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        if let data = UIImageJPEGRepresentation(image, 0.5) as Data? {

            let filename = Date().timeIntervalSince1970

            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("photos/\(placeId)/\(filename).jpg")

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
                    
                    //Add URL to firebase for retrieval
                    let ref = FIRDatabase.database().reference()
                    let images = ref.child("locationImages/\(placeId)")
                    let userImages = ref.child("userImages/\(userId)")
                    
                    let newImage = [
                        "url": downloadURL.absoluteString,
                        "userId": userId,
                        "description": description,
                        "placeId": placeId,
                        "timestamp": FIRServerValue.timestamp(),
                    ] as [String : Any]
                    
                    images.childByAutoId().setValue(newImage)
                    userImages.childByAutoId().setValue(newImage)
                    
                    completion(true)
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
        
        let like = ref.child("likes/\(userId)--\(locationId)")
        
        like.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func userLikesCount(userId: String, completion: @escaping (Int) -> ()) {
        let ref = FIRDatabase.database().reference()
        
        let likes = ref.child("likes").queryOrderedByKey().queryStarting(atValue: userId)
        
        var likesCount = 0
        likes.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                for child in snapshot.children {
                    let data = child as! FIRDataSnapshot
                    if (data.key.hasPrefix(userId)) {
                        likesCount = likesCount + 1
                    } else {
                        break
                    }
                }
                
                completion(likesCount)
            } else {
                completion(0)
            }
        })
    }
    
    func userVisitsCount(userId: String, completion: @escaping (Int) -> ()) {
        let ref = FIRDatabase.database().reference()
        
        let likes = ref.child("visits").queryOrderedByKey().queryStarting(atValue: userId)
        
        var likesCount = 0
        likes.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                for child in snapshot.children {
                    let data = child as! FIRDataSnapshot
                    if (data.key.hasPrefix(userId)) {
                        likesCount = likesCount + 1
                    } else {
                        break
                    }
                }
                
                completion(likesCount)
            } else {
                completion(0)
            }
        })
    }
    
    func getUserImageMetadata(userId: String, completion: @escaping ([LocationImage]) -> ()) {
        let ref = FIRDatabase.database().reference()
        let imageURLs = ref.child("userImages/\(userId)")
        var locationImages = [LocationImage]()
        
        imageURLs.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let data = child as! FIRDataSnapshot
                
                let url = data.childSnapshot(forPath: "url").value as! String
                let description = data.childSnapshot(forPath: "description").value as? String ?? ""
                let userId = data.childSnapshot(forPath: "userId").value as! String
                let timestamp = data.childSnapshot(forPath: "timestamp").value as? TimeInterval
                let placeId = data.childSnapshot(forPath: "placeId").value as! String
                
                var formattedTimestamp = ""
                let date = Date(timeIntervalSince1970: timestamp!/1000)
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY"
                formattedTimestamp = formatter.string(from: date)
                
                let location = LocationImage(imageURL: url, description: description, userId: userId, timestamp: formattedTimestamp, placeId: placeId)
                
                locationImages.append(location)
            }
            
            completion(locationImages)
        })
    }
    
    func getLocationImageMetadata(placeId: String, completion: @escaping ([LocationImage]) -> ()) {
        let ref = FIRDatabase.database().reference()
        let imageURLs = ref.child("locationImages/\(placeId)")
        var locationImages = [LocationImage]()
        
        imageURLs.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let data = child as! FIRDataSnapshot
                
                let url = data.childSnapshot(forPath: "url").value as! String
                let description = data.childSnapshot(forPath: "description").value as? String ?? ""
                let userId = data.childSnapshot(forPath: "userId").value as! String
                let timestamp = data.childSnapshot(forPath: "timestamp").value as? TimeInterval
                
                var formattedTimestamp = ""
                let date = Date(timeIntervalSince1970: timestamp!/1000)
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY"
                formattedTimestamp = formatter.string(from: date)
                
                let location = LocationImage(imageURL: url, description: description, userId: userId, timestamp: formattedTimestamp, placeId: placeId)
  
                locationImages.append(location)
            }
            
            completion(locationImages)
        })
    }
    
    func getLocationImage(url: String,  completion: @escaping (UIImage) -> ()) {
        
        let storage = FIRStorage.storage()
        let storageRef = storage.reference(forURL: url)
        
        storageRef.data(withMaxSize: (10 * 1024 * 1024)) { (data, error) -> Void in
            let image = UIImage(data: data!)
            completion(image!)
        }
    }
}
