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
    static let navigationBarColor = UIColor(red: 87/255, green: 79/255, blue: 124/255, alpha: 1.0)
    static let selectedCellColor = UIColor(red: 75/255, green: 64/255, blue: 127/255, alpha: 1)
    
    static func customizeTextAppearance(text: String) -> NSAttributedString {
        //        let shadow = NSShadow()
        //        shadow.shadowColor = UIColor.darkGray
        //        shadow.shadowOffset = CGSize(width: 2, height: 2)
        //        shadow.shadowBlurRadius = 4
        let attributeColor = UIColor.white
        
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: attributeColor/*,NSShadowAttributeName: shadow*/])
    }
    
    static func customizeNavigationBar(navigationController: UINavigationController?) {
        navigationController?.navigationBar.barTintColor = navigationBarColor
        navigationController?.navigationBar.tintColor = .white
    }

    static func customizeTextAppearance1(text: String) -> NSAttributedString {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowBlurRadius = 4
        let attributeColor = UIColor.white
        
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: attributeColor,NSShadowAttributeName: shadow])
    }
    
    static func setStatusBarBackgroundColor() {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = UIColor.fl_primary_dark
    }
    
}

extension UIColor {
    
    static let fl_primary = UIColor.init(fromHexString: "#673AB7FF")
    static let fl_primary_dark = UIColor.init(fromHexString: "#512DA8FF")
    static let fl_primary_light = UIColor.init(fromHexString: "#D1C4E9FF")
    static let fl_accent = UIColor.init(fromHexString: "#00BCD4FF")
    static let fl_primary_text = UIColor.init(fromHexString: "#212121FF")
    static let fl_secondary_text = UIColor.init(fromHexString: "#757575FF")
    static let fl_icons = UIColor.init(fromHexString: "#FFFFFFFF")
    static let fl_divider = UIColor.init(fromHexString: "#BDBDBDFF")
    
    
    public convenience init?(fromHexString: String) {
        let r, g, b, a: CGFloat
        
        if fromHexString.hasPrefix("#") {
            let start = fromHexString.characters.index(fromHexString.startIndex, offsetBy: 1)
            let hexColor = fromHexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat((hexNumber & 0x000000ff)     ) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }

    
}
