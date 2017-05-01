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
    
    static func loadData() -> [FirebaseMovie] {
        var moviesArray: [FirebaseMovie] = []
        
        /* Find the path of the file */
        if let filePath = Bundle.main.path(forResource: "InputMoviesData", ofType: "json") {
            /* Load it's content in a var */
            if let fileContent = try? String(contentsOfFile: filePath) {
                let jsonArray = JSON(parseJSON: fileContent)
                for json in jsonArray.arrayValue {
                    moviesArray.append(FirebaseMovie(json: json))
                }
            }
        }
        
        return moviesArray
    }
}
