//
//  MenuViewController.swift
//  Film Locations
//
//  Created by Laura on 4/27/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    var firstViewController: UIViewController?
    var secondViewController: UIViewController?
    private var toggleButton = UIButton()
    
    private var activeViewController: UIViewController? {
        didSet{
            removeInactiveViewController(inactiveViewController: oldValue)
            updateActiveViewController()
        }
    }
    
    private var toggleButtonImage: UIImage {
        get {
            return toggleButton.currentImage!
        }
        set {
            toggleButton.setImage(newValue, for: UIControlState.normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupToggleButton()
        activeViewController = firstViewController
    }
    
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inactiveVC = inactiveViewController {
            // called before removing child view controller's view form hierarchy
            inactiveVC.willMove(toParentViewController: nil)
            
            inactiveVC.view.removeFromSuperview()
            
            // called after removing child view controller's view from hierarchy
            inactiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController {
            // called before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = contentView.bounds
            contentView.addSubview(activeVC.view)
            
            // call before adding child view contoller's view as subview
            activeVC.didMove(toParentViewController: self)
            activeViewController?.view.addSubview(toggleButton)
        }
    }
    
    private func setupToggleButton() {
        toggleButton.frame = CGRect(x: 13, y: 18, width: 30, height: 30)
        updateToggleButtonIcon(with: InternalConfiguration.listToggleIcon)
        toggleButton.addTarget(self, action: #selector(toggleActiveView(_:)), for: UIControlEvents.touchUpInside)
        
        // add the toggle to the view controller
        activeViewController?.view.addSubview(toggleButton)
    }
    
    private func updateToggleButtonIcon(with image: String) {
        toggleButtonImage = UIImage(named: image)!
    }
    
    func toggleActiveView(_ sender: UIButton) {
        if activeViewController == firstViewController {
            activeViewController = secondViewController
            updateToggleButtonIcon(with: InternalConfiguration.mapToggleIcon)
        }
        else {
            activeViewController = firstViewController
            updateToggleButtonIcon(with: InternalConfiguration.listToggleIcon)
        }
    }

}
