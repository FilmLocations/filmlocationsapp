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
            descriptionLabel.text = ""
            timeLabel.text = ""
            userNameLabel.text = ""
            poweredByGoogleImage.isHidden = false
            imageInfoView.isHidden = true
        }
        
        userNameLabel.textColor = UIColor.white
        timeLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
        
        let button1 = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onBackButton))
        button1.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = button1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
