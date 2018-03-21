//
//  AboutViewController.swift
//  Film Locations
//
//  Created by Laura on 5/4/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController, MenuContentViewControllerProtocol {

    @IBOutlet weak var appIconImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var appIconBorderView: UIView!
    
    var delegate: MenuButtonPressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appIconImage.layer.cornerRadius = 4
        appIconImage.layer.masksToBounds = true
        appIconBorderView.layer.cornerRadius = 4
        appIconBorderView.layer.masksToBounds = true
    }

    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }
    
    @IBAction func openDataSFSite(_ sender: UITapGestureRecognizer) {
        openSite(url: URL(string: "https://datasf.org/opendata/")!)
    }
    
    @IBAction func openTMDBSite(_ sender: UITapGestureRecognizer) {
        openSite(url: URL(string: "https://www.themoviedb.org/")!)
    }
    
    func openSite(url: URL) {
        let svc = SFSafariViewController(url: url)
        
        if #available(iOS 11.0, *) {
            svc.preferredBarTintColor = UIColor.fl_primary_dark
            svc.preferredControlTintColor = UIColor.white
        } else {
            svc.view.tintColor = UIColor.fl_primary_dark
        }
        
        present(svc, animated: true)
    }
}
