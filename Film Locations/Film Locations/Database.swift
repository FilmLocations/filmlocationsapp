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
    
    // TODO return array of Film objects
    static func getAllFilms() {
        
        let ref = FIRDatabase.database().reference()
        
        let films = ref.child("films")
        
        films.observe(.value, with: { (snapshot) in
            let films = snapshot.value as? [String: Any] ?? [:]
            
            for film in films {
                // TODO build using Film model object
                print("Film is ", film)
            }
        })
    }
    
    // TODO return Film object
    static func getFilm(filmId: String) {
        
        let ref = FIRDatabase.database().reference()

        let films = ref.child("films/\(filmId)")

        films.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let film = snapshot.value as? [String: Any] ?? [:]
            
            print("Selected film is", film)
        })
    }
    
    static func addPhoto(userId: String, locationId: String, image: UIImage) {
        
        print("Adding photo for \(userId) to \(locationId) of \(image.description)")
        
        // Get a reference to the storage service using the default Firebase App
        let storage = FIRStorage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        if let data = UIImagePNGRepresentation(image) as Data? {
            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("images/test.jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = imageRef.put(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("Error uploading photo \(error.debugDescription)")
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                print("download url \(downloadURL)")
            }
        }
        
    }
    
    static func visitLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let visits = ref.child("visits")
        
        visits.child("\(userId)--\(locationId)").setValue(["timestamp": FIRServerValue.timestamp()])
    }
    
    static func likeLocation(userId: String, locationId: String) {
        let ref = FIRDatabase.database().reference()
        let likes = ref.child("likes")
        
        likes.child("\(userId)--\(locationId)").setValue(["timestamp": FIRServerValue.timestamp()])

    }
    
    static func hasVisitedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        let ref = FIRDatabase.database().reference()

        let visit = ref.child("visits/\(userId)--\(locationId)")
        
        visit.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value != nil) {
                completion(true)
            }
        })
        
        completion(false)
    }
    
    static func hasLikedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        let ref = FIRDatabase.database().reference()
        
        let like = ref.child("like/\(userId)--\(locationId)")
        
        like.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value != nil) {
                completion(true)
            }
        })
        
        completion(false)
    }
}
