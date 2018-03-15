//
//  GradientView.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 3/12/18.
//  Copyright © 2018 Codepath Spring17. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
    @IBInspectable var startColor = UIColor.white
    @IBInspectable var endColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [startColor.cgColor, endColor.cgColor]
    }
}
