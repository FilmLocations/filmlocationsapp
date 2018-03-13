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

    static let navigationBarColor = UIColor.fl_primary_dark
    static let selectedCellColor = UIColor.fl_secondary_text
    
    static func customizeTextAppearance(text: String) -> NSAttributedString {
        let attributeColor = UIColor.white
        
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: attributeColor])
    }
    
    static func customizeNavigationBar(navigationController: UINavigationController?) {
        navigationController?.navigationBar.barTintColor = navigationBarColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    static func setStatusBarBackgroundColor() {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = UIColor.fl_primary_dark
        
    }
}

extension UILabel{
    @objc dynamic var defaultFont: UIFont? {
        get { return self.font }
        set {
            let sizeOfOldFont = self.font.pointSize
            let fontNameOfNewFont = newValue?.fontName
            self.font = UIFont(name: fontNameOfNewFont!, size: sizeOfOldFont)
        }
    }
}

extension UIColor {

    static let fl_primary = UIColor.init(fromHexString: "#212121FF")
    static let fl_primary_dark = UIColor.init(fromHexString: "#000000FF")
    static let fl_primary_light = UIColor.init(fromHexString: "#333333FF")
    static let fl_accent = UIColor.init(fromHexString: "#00BCD4FF")
    static let fl_primary_text = UIColor.init(fromHexString: "#f2f2f2FF")
    static let fl_secondary_text = UIColor.init(fromHexString: "#a6a6a6FF")
    static let fl_icons = UIColor.init(fromHexString: "#FFFFFFFF")
    static let fl_divider = UIColor.init(fromHexString: "#BDBDBDFF")
    static let fl_secondary = UIColor.init(fromHexString: "#00BCD4FF")
    static let fl_secondary_700 = UIColor.init(fromHexString: "#0097A7FF")
    static let fl_secondary_200 = UIColor.init(fromHexString: "#80DEEAFF")

    public convenience init?(fromHexString: String) {
        let r, g, b, a: CGFloat
        
        if fromHexString.hasPrefix("#") {
            let start = fromHexString.index(fromHexString.startIndex, offsetBy: 1)
            let hexColor = String(fromHexString[start...])
            
            if hexColor.count == 8 {
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
