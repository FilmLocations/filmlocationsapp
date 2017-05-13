//
//  AboutViewController.swift
//  Film Locations
//
//  Created by Laura on 5/4/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, MenuContentViewControllerProtocol {

    var delegate: MenuButtonPressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }
}
