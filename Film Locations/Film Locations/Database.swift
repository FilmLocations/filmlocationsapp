//
//  Database.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AWSCore
import AWSCognito
import AWSS3

class Database {
    
    static let shared: Database = {
        let instance = Database()
        return instance
    }()
    
    private let databaseURL: String!
    private let credentialsProvider: AWSCognitoCredentialsProvider?
    private let formatter = DateFormatter()
    private let isoFormatter = ISO8601DateFormatter()
    private var movieLocations: [FilmLocation] = []

    private init() {
        
        print("Initializing Database")
        
        if let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!) {
            let AWSCognitoCredentialsIdentityPoolID = keys["AWSCognitoCredentialsIdentityPoolID"] as! String
            
            // Initialize the Amazon Cognito credentials provider
            credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2,
                                                                identityPoolId: AWSCognitoCredentialsIdentityPoolID)

            databaseURL = keys["FilmLocationsServiceURL"] as! String
            
            formatter.dateFormat = "MMM dd, YYYY"
        } else {
            credentialsProvider = nil
            databaseURL = ""
            print("Keys file missing!")
        }
    }
    
    
    func getAllLocations(completion: @escaping ([FilmLocation]) -> ()) {
        
        if movieLocations.count > 0 {
            completion(movieLocations)
            return
        }
        
        Alamofire.request(databaseURL + "locations").responseJSON { response in
        
            if let value = response.result.value {
                
                let json = JSON(value)
                
                for location in json {
                    self.movieLocations.append(FilmLocation(json: location.1))
                }
                
                completion(self.movieLocations)
            }
        }
    }

    func addPhoto(userId: String, locationId: String, placeId: String, image: UIImage, description: String, completion: @escaping (Bool) -> ()) {
        print("Adding photo for \(userId) to \(locationId)")
        
        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let testFileURL1 = URL(fileURLWithPath: NSTemporaryDirectory().appendingFormat("temp"))
        let data = UIImageJPEGRepresentation(image, 0.5)
        
        do {
            try data!.write(to: testFileURL1)
        } catch  {
            print("Couldn't write file")
        }

        let filename = Date().timeIntervalSince1970

        
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.bucket = "filmlocations"
            uploadRequest.key = "\(filename).png"
            uploadRequest.body = testFileURL1
            
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                
                if let error = task.error as NSError? {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error uploading: \(uploadRequest.key!) Error: \(error)")
                        }
                    } else {
                        print("Error uploading: \(uploadRequest.key!) Error: \(error)")
                    }
                    return nil
                }
                
                let uploadOutput = task.result
                print("Upload output is \(uploadOutput!)")
                print("Upload complete for: \(uploadRequest.key!)")
                
                let parameters = [
                    "name": "\(filename).png",
                    "userId": userId,
                    "description": description,
                    "placeId": placeId,
                    "locationId": locationId
                    ] as [String : Any]
                print("send to images API \(parameters)")

                Alamofire.request(self.databaseURL + "images", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    completion(true)
                }
                
                return nil
            })
        }
    }

    func visitLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/visit/\(userId)", method: .post).responseJSON { response in
                completion(true)
        }
    }
    
    func removeVisitLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/visit/\(userId)", method: .delete).responseJSON { response in
            completion(true)
        }
    }

    func likeLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
       
        Alamofire.request(databaseURL + "locations/\(locationId)/like/\(userId)", method: .post).responseJSON { response in
            completion(true)
        }
    }
    
    func removeLikeLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/like/\(userId)", method: .delete).responseJSON { response in
            completion(true)
        }
    }

    func hasVisitedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/visit/\(userId)").responseJSON { response in
            guard let hasVisited = response.result.value as? Bool else {
                completion(false)
                return
            }
            completion(hasVisited)
        }
    }
    
    func hasLikedLocation(userId: String, locationId: String, completion: @escaping (Bool) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/like/\(userId)").responseJSON { response in
            if let hasLiked = response.result.value as? Bool {
                completion(hasLiked)
            } else {
                completion(false)
            }
        }
    }
    
    func userLikesCount(userId: String, completion: @escaping (Int) -> ()) {
        
        Alamofire.request(databaseURL + "users/\(userId)/likes").responseJSON { response in
            if let count = response.result.value as? Int {
                completion(count)
            } else {
                completion(0)
            }
        }
    }
    
    func locationLikesCount(locationId: String, completion: @escaping (Int) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/likes").responseJSON { response in
            if let count = response.result.value as? Int {
                completion(count)
            } else {
                completion(0)
            }
        }
    }
    
    func locationVisitsCount(locationId: String, completion: @escaping (Int) -> ()) {
        
        Alamofire.request(databaseURL + "locations/\(locationId)/visits").responseJSON { response in
            if let count = response.result.value as? Int {
                completion(count)
            } else {
                completion(0)
            }
        }
    }
    
    func userVisitsCount(userId: String, completion: @escaping (Int) -> ()) {
        
        Alamofire.request(databaseURL + "users/\(userId)/visits").responseJSON { response in
            if let count = response.result.value as? Int {
                completion(count)
            } else {
                completion(0)
            }
        }
    }
    
    func getUserImageMetadata(userId: String, completion: @escaping ([LocationImage]) -> ()) {
        
        Alamofire.request(databaseURL + "images?userId=\(userId)", encoding: JSONEncoding.default).responseJSON { response in
            var locationImages = [LocationImage]()
            
            if let value = response.result.value {
                
                let json = JSON(value)
                
                for location in json {
        
                    let location = self.convertLocationImageData(location: location)
                    
                    locationImages.append(location)
                }
                print("Images list is \(locationImages)")
                
                completion(locationImages)
            }
        }
    }
    
    func getLocationImageMetadata(locationId: String, completion: @escaping ([LocationImage]) -> ()) {
        Alamofire.request(databaseURL + "images?locationId=\(locationId)", encoding: JSONEncoding.default).responseJSON { response in
            var locationImages = [LocationImage]()
            
            if let value = response.result.value {
                
                let json = JSON(value)
                
                for location in json {
                    
                    let location = self.convertLocationImageData(location: location)
                    
                    locationImages.append(location)
                }
                print("Images list is \(locationImages)")
                
                completion(locationImages)
            }
        }
    }
    
    func convertLocationImageData(location: (String, JSON)) -> LocationImage {
        
        let locationId = location.1["_id"]["$oid"].stringValue
        let fileName = location.1["name"].stringValue
        let description = location.1["description"].stringValue
        let userId = location.1["userId"].stringValue
        let timestamp = location.1["date"]["$date"].stringValue
        let placeId = location.1["placeId"].stringValue
        
        var formattedTimestamp = ""
        
        let trimmedIsoString = timestamp.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        
        if let date = isoFormatter.date(from: trimmedIsoString) {
            formattedTimestamp = formatter.string(from: date)
        }
        
        let location = LocationImage(locationId: locationId, imageName: fileName, description: description, userId: userId, timestamp: formattedTimestamp, placeId: placeId)
        
        return location
    }
    
    func getLocationImage(filename: String,  completion: @escaping (UIImage) -> ()) {
        
        print("Getting image with URL \(filename)")
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        if let downloadRequest = AWSS3TransferManagerDownloadRequest() {
            downloadRequest.bucket = "filmlocations"
            downloadRequest.key = filename
            downloadRequest.downloadingFileURL = downloadingFileURL
            
            let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            let transferManager = AWSS3TransferManager.default()

            transferManager.download(downloadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                
                if let error = task.error as NSError? {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error downloading: \(downloadRequest.key!) Error: \(error)")
                        }
                    } else {
                        print("Error downloading: \(downloadRequest.key!) Error: \(error)")
                    }
                    return nil
                }
                print("Download complete for: \(downloadRequest.key!)")
                //let downloadOutput = task.result
                
                let image = UIImage(contentsOfFile: downloadingFileURL.path)
                
                completion(image!)
                return nil
            })
        }
    }
}
