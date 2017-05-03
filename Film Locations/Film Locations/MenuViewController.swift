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
        activeViewController = firstViewController
        setupToggleButton()
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
            //activeViewController?.view.addSubview(toggleButton)
            
            setupToggleButton()
        }
    }
    
    private func setupToggleButton() {
        toggleButton.frame =  CGRect.zero
        updateToggleButtonIcon(with: InternalConfiguration.listToggleIcon)
        toggleButton.addTarget(self, action: #selector(toggleActiveView(_:)), for: UIControlEvents.touchUpInside)
        
        // add the toggle to the view controller
        activeViewController?.view.addSubview(toggleButton)
        
        if let activeView = activeViewController?.view {
        
            toggleButton.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = toggleButton.topAnchor.constraint(equalTo: activeView.topAnchor, constant: 22.0)
            let leadingConstraint = toggleButton.leadingAnchor.constraint(equalTo: activeView.leadingAnchor, constant: 16.0)
            
            let widthConstraint = toggleButton.widthAnchor.constraint(equalToConstant: 30.0)
            let heightConstraint = toggleButton.heightAnchor.constraint(equalToConstant: 30.0)
            
            NSLayoutConstraint.activate([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
            
        }

        
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
