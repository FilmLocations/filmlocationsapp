//
//  FullscreenViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/7/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class FullscreenViewController: UIViewController {
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    var locationImageMetadata: LocationImage!
    var locationImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        locationImageView.image = locationImage
        
        if let locationImageMetadata = locationImageMetadata {
            userNameLabel.text = "@\(locationImageMetadata.userId)"
            descriptionLabel.text = locationImageMetadata.description
            timeLabel.text = locationImageMetadata.timestamp
        } else {
            descriptionLabel.text = "Image via Google"
            timeLabel.text = ""
            userNameLabel.text = ""
        }

        view.backgroundColor = UIColor.fl_primary_dark
        userNameLabel.textColor = UIColor.fl_accent
        timeLabel.textColor = UIColor.fl_accent
        descriptionLabel.textColor = UIColor.fl_primary_text
        backButton.tintColor = UIColor.fl_accent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
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
