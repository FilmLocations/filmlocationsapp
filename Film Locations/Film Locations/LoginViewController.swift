//
//  LoginViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/7/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import Pastel
import TwitterKit

class LoginViewController: UIViewController {

    @IBOutlet weak var continueWithoutLoginButton: UIButton!
    @IBOutlet weak var filmLocationsLabel: UILabel!
    @IBOutlet weak var sanFranciscoLabel: UILabel!
    @IBOutlet weak var twitterLoginButton: TWTRLogInButton!
    
    // Used for enforcing the initial center of the twitterLoginButton
    @IBOutlet weak var dummyTwitterLoginButton: UIButton!
    
    var pastelView = PastelView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // If we go to login screen but there's already a user, log them out
        if (User.currentUser != nil) {
            let store = TWTRTwitter.sharedInstance().sessionStore
            
            if let userID = store.session()?.userID {
                store.logOutUserID(userID)
                User.currentUser = nil
            }
        }
        
        twitterLoginButton.center = dummyTwitterLoginButton.center

        twitterLoginButton.logInCompletion = { session, error in
            
            if (session != nil) {
                print("signed in as \(session!.userName)");
                
                let client = TWTRAPIClient()
                client.loadUser(withID: session!.userID, completion: { (user, error) in
                    User.currentUser = User(screenName: (user?.screenName)!, name: user?.name, formattedScreenName: (user?.formattedScreenName)!, profileImageURL: user?.profileImageLargeURL, profileURL: user?.profileURL)
                    self.goToMain()
                })
                
            } else {
                // TODO handle login failure
                print("error: \(error!.localizedDescription)");
            }
            
        }

        continueWithoutLoginButton.layer.cornerRadius = 4
        continueWithoutLoginButton.backgroundColor = UIColor.fl_primary_dark
        continueWithoutLoginButton.titleLabel?.textColor = UIColor.fl_primary_text
     
        pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 2.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 0/255, green: 188/255, blue: 212/255, alpha: 1.0),
                                      UIColor(red: 0/255, green: 180/255, blue: 204/255, alpha: 1.0),
                                      UIColor(red: 0/255, green: 158/255, blue: 179/255, alpha: 1.0),
                                      UIColor(red: 0/255, green: 90/255, blue: 102/255, alpha: 1.0),
                                      UIColor(red: 0/255, green: 135/255, blue: 153/255, alpha: 1.0),
                                      UIColor(red: 0/255, green: 113/255, blue: 128/255, alpha: 1.0),
                                      UIColor(red: 0/255, green: 90/255, blue: 102/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
        
        filmLocationsLabel.defaultFont = UIFont(name: "Angelface", size: 70)
        sanFranciscoLabel.defaultFont = UIFont(name: "Angelface", size: 70)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onContinueWithoutLogin(_ sender: Any) {
        goToMain()
    }
    
    func goToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hvc = storyboard.instantiateViewController(withIdentifier: "HamburgerView") as! HamburgerViewController
    
        present(hvc, animated: true, completion: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        pastelView.bindFrameToSuperviewBounds()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {
    
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
}
