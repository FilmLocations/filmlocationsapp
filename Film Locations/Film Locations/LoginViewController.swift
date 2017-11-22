//
//  LoginViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/7/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import Pastel

class LoginViewController: UIViewController {

    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var continueWithoutLoginButton: UIButton!
    @IBOutlet weak var appTitle: UILabel!

    var pastelView = PastelView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // If we go to login screen but there's already a user, log them out
        if (User.currentUser != nil) {
            TwitterClient.sharedInstance?.logout()
        }
        
        twitterLoginButton.layer.cornerRadius = 4
        continueWithoutLoginButton.layer.cornerRadius = 4

        continueWithoutLoginButton.backgroundColor = UIColor.fl_primary_dark
        continueWithoutLoginButton.titleLabel?.textColor = UIColor.fl_primary_text
     
        pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 3.0
        
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
        
        appTitle.defaultFont = UIFont(name: "Angelface", size: 70)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTwitterLogin(_ sender: Any) {
        TwitterClient.sharedInstance?.login(success: {            
            self.goToMain()
            
        }, failure: { (error: Error) in
            print("Error: \(error.localizedDescription)")
        })
    }

    @IBAction func onContinueWithoutLogin(_ sender: Any) {
        goToMain()
    }
    
    func goToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hvc = storyboard.instantiateViewController(withIdentifier: "HamburgerView") as! HamburgerViewController
        self.present(hvc, animated: true, completion: nil)
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
