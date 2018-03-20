//
//  User.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//
import UIKit

class User: NSObject {
    
    var screenname: String!
    var name: String?
    var formattedScreenName: String?
    var profileImageURL: String?
    var profileURL: URL?
    var isAnonymous = false

    init(screenName: String, name: String?, formattedScreenName: String?, profileImageURL: String?, profileURL: URL?) {
        
        self.screenname = screenName
        self.name = name
        self.formattedScreenName = formattedScreenName
        self.profileImageURL = profileImageURL
        self.profileURL = profileURL
    }
    
    private static var _currentUser: User?
    
    class var currentUser: User {
        get {
            if _currentUser == nil {
                let user = User(screenName: "anonymous", name: "anonymous", formattedScreenName: "anonymous", profileImageURL: nil, profileURL: nil)
                user.isAnonymous = true
                return user
            } else {
                return _currentUser!
            }
        }
        set (user) {
            user.isAnonymous = false
            _currentUser = user
        }
    }
    
    override var description: String {
        return "Username is \(screenname)"
    }
}
