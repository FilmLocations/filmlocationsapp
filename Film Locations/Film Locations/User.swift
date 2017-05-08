//
//  User.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import UIKit

class User: NSObject {
    
    var name: String?
    var screenname: String!
    var profileUrl: URL?
    var dictionary: [String: Any]
    var location: String?
    var isAnonymous = false

    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        location = dictionary["location"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let userInfo = [
                    "name" : "anonymous",
                    "screen_name" : "anonymous" ]
                let user = User(dictionary: userInfo)
                user.isAnonymous = true
                return user
            } else {
                return _currentUser
            }
        }
        set (user) {
            user?.isAnonymous = false
            _currentUser = user
        }
    }
}
