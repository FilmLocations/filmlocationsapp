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
    @IBOutlet weak var poweredByGoogleImage: UIImageView!
    @IBOutlet weak var imageInfoView: UIView!
    @IBOutlet weak var closeButton: UIImageView!
    
    var locationImageMetadata: LocationImage!
    var locationImage: UIImage!
    var googleAttribution: NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.fl_primary_dark
        
        // Do any additional setup after loading the view.
        
        locationImageView.image = locationImage
        
        if let locationImageMetadata = locationImageMetadata {
            userNameLabel.text = "@\(locationImageMetadata.userId)"
            descriptionLabel.text = locationImageMetadata.description
            timeLabel.text = locationImageMetadata.timestamp
        } else {
            
            if let googleAttribution = googleAttribution {
                let attribution = NSMutableAttributedString(string: "By ")
                attribution.append(googleAttribution)
                descriptionLabel.attributedText = attribution
            } else {
                descriptionLabel.text = ""
            }
            
            timeLabel.isHidden = true
            userNameLabel.isHidden = true
            poweredByGoogleImage.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        if imageInfoView.alpha > 0 {
            UIView.animate(withDuration: 0.3) {
                self.imageInfoView.alpha = 0
                self.closeButton.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.imageInfoView.alpha = 0.7
                self.closeButton.alpha = 1
            }
        }
    }
}
