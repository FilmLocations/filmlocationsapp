//
//  PostViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 5/6/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var postImage: UIImage!
    var postPlaceId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        postImageView.image = postImage

        postButton.tintColor = UIColor.fl_primary
        cancelButton.tintColor = UIColor.fl_primary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPostButton(_ sender: Any) {
        let screenName = User.currentUser!.screenname!
        let description = descriptionTextField.text ?? ""
        
        Database.sharedInstance.addPhoto(userId: screenName, placeId: postPlaceId, image: postImage, description: description) { (completed) in
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func onCancelButton(_ sender: Any) {
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
