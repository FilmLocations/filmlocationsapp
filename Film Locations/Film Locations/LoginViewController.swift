//
//  LoginViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/7/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var continueWithoutLoginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // If we go to login screen but there's already a user, log them out
        if (User.currentUser != nil) {
            TwitterClient.sharedInstance?.logout()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTwitterLogin(_ sender: Any) {
        TwitterClient.sharedInstance?.login(success: {            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let hvc = storyboard.instantiateViewController(withIdentifier: "HamburgerView") as! HamburgerViewController
            self.present(hvc, animated: true, completion: nil)
            
        }, failure: { (error: Error) in
            print("Error: \(error.localizedDescription)")
        })
        
    }

    @IBAction func onContinueWithoutLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hvc = storyboard.instantiateViewController(withIdentifier: "HamburgerView") as! HamburgerViewController
        self.present(hvc, animated: true, completion: nil)
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
