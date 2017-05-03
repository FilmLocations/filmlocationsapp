//
//  InternalConfiguration.swift
//  Film Locations
//
//  Created by Laura on 4/27/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import SwiftyJSON

struct InternalConfiguration {
    static let mapToggleIcon = "mapToggleIcon"
    static let listToggleIcon = "listToggleIcon"
    
    static func customizeTextAppearance(text: String) -> NSAttributedString {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.darkGray
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowBlurRadius = 4
        let attributeColor = UIColor.white
        
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: attributeColor,NSShadowAttributeName: shadow])
    }
    
}
