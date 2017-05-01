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
    
    static func getAllFilms(completion: @escaping ([Movie]) -> ()) {
        
        let ref = FIRDatabase.database().reference()
        let films = ref.child("films")
        
        var movies = [Movie]()

        films.observe(.value, with: { (snapshot) in
            
            for child in snapshot.children {
                let data = child as! FIRDataSnapshot

                let movie = self.buildMovieObject(data: data)
                movies.append(movie)
            }

            completion(movies)
        })
    }
    
    static func getFilm(filmId: Int, completion: @escaping (Movie) -> ()) {
        let ref = FIRDatabase.database().reference()

        ref.child("films")
            .queryOrdered(byChild: "id")
            .queryEqual(toValue: filmId)
            .queryLimited(toFirst: 1)
            .observeSingleEvent(of: .value, with: {(snapshot) in
                for child in snapshot.children {
                    let data = child as! FIRDataSnapshot

                    let movie = self.buildMovieObject(data: data)

                    completion(movie)
                }
        })
    }
    
    class func buildMovieObject(data: FIRDataSnapshot) -> Movie {
        let value = data.value! as! [String: Any]

        //print(value)

        // TODO If some of these values are not set, we don't have a valid movie
        let id = value["id"] as? Int ?? 0
        let movieId = Int(id)

        let title = value["title"] as? String ?? ""

        let release = value["release"] as? [String: Any] ?? [:]
        let year = release["year"] as? String ?? ""

        let images = value["images"] as? [String: Any] ?? [:]
        let posterImageName = images["poster"] as? String ?? ""
        let posterImageFullURL = "http://image.tmdb.org/t/p/w185/\(posterImageName)"
        let posterImageURL = URL(string: posterImageFullURL)
        
        let location = value["location"] as? [String: Any] ?? [:]
        let locationAddress = location["address"] as? String ?? ""
        let gps = location["gps"] as? [String: Any] ?? [:]
        let gpsLocation = gps["location"] as? [String: Any] ?? [:]
        let placeId = gps["place_id"] as? String ?? ""
        let lat = gpsLocation["lat"] as? Double ?? 0
        let long = gpsLocation["lng"] as? Double ?? 0
        
        let locationObject = Location(placeId: placeId, address: locationAddress, lat: lat, long: long)

        let movie = Movie(id: movieId, title: title, releaseYear: year, posterImageURL: posterImageURL, locations: [locationObject], isExpanded: false)

        return movie
    }

    static func addPhoto(userId: String, locationId: String, image: UIImage) {
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
    
    static func visitLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let visits = ref.child("visits")
        
        visits.child("\(userId)--\(locationId)").setValue(["timestamp": FIRServerValue.timestamp()])
    }
    
    static func removeVisitLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let visits = ref.child("visits")

        visits.child("\(userId)--\(locationId)").removeValue()
    }

    static func likeLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let likes = ref.child("likes")
        
        likes.child("\(userId)--\(locationId)").setValue(["timestamp": FIRServerValue.timestamp()])
    }
    
    static func removeLikeLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let likes = ref.child("likes")

        likes.child("\(userId)--\(locationId)").removeValue()
    }

    static func hasVisitedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
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
    
    static func hasLikedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
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
