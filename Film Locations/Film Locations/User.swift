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
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            let user = User()
            user.name = "Anonymous"
            user.screenname = "Anonymous"
            
            return user
        }
    }
}
