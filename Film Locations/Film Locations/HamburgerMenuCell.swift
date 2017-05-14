//
//  HamburgerMenuCell.swift
//  Film Locations
//
//  Created by Laura on 5/9/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class HamburgerMenuCell: UITableViewCell {

    @IBOutlet weak var menuSymbolImageView: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!
    
    var option: MenuOption? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        // clean all existing data
        menuSymbolImageView.image = nil
        menuLabel.text = nil
        self.backgroundColor = UIColor.fl_primary_dark
        
        if let option = option {
            menuSymbolImageView.image = UIImage(named: option.symbol)
            menuLabel.text = option.text
        }
    }
}
