//
//  ActivityIndicator.swift
//  Flicks
//
//  Created by Niraj Pendal on 3/30/17.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit

public class ActivityIndicator : UIActivityIndicatorView {
    
    
    private var container : UIView = UIView()
    private var loadingView : UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    public func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        loadingView.frame = CGRect(x: 0, y:0,  width:80, height:80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.black
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x:loadingView.frame.size.width / 2,y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicator(view: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
}
