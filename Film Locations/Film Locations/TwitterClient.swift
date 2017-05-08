//
//  Twitter.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/7/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "qF3GN30fkGocKNf0mEFRJy3jT", consumerSecret: "wUkvBtU1dOCnNw5wmswo40ckeYpKVQDTAxg6snMKwZQ5Lfa5h5")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance?.deauthorize() // clear previous sessions
        
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "https://api.twitter.com/oauth/request_token", method: "GET", callbackURL: URL(string: "filmLocations://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            
            let urlString = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)"
            let url = URL(string: urlString)!
            UIApplication.shared.open(url)
            
        }) { (error: Error!) -> Void in
            print("error \(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
    }
    
    func handleOpenUrl(url: URL) {
        
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            
            self.currentAccount(success: { (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) -> () in
                self.loginFailure?(error)
            })
            
            self.loginSuccess?()
            
        }) { (failure: Error!) -> Void in
            print("error: \(failure.localizedDescription)")
            self.loginFailure?(failure)
        }
    }
    
    func getUserProfile(screenname: String, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/users/show.json?screen_name=\(screenname)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            //print("account: \(response.debugDescription)")
            
            let userDictionary = response as! [String: Any]
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error?) -> Void in
            print("error: \(error!.localizedDescription)")
            failure(error!)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            //print("account: \(response.debugDescription)")
            
            let userDictionary = response as! [String: Any]
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error?) -> Void in
            print("error: \(error!.localizedDescription)")
            failure(error!)
        })
        
    }
}
