//
//  HamburgerViewController.swift
//  Film Locations
//
//  Created by Laura on 5/4/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

protocol MenuContentViewControllerProtocol {
    var delegate: MenuButtonPressDelegate? {get set}
}

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    var originalLeftMargin: CGFloat!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuViewController.willMove(toParentViewController: self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil  {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            self.addChildViewController(contentViewController)
            contentViewController.willMove(toParentViewController: self)
            
            // Adding shadow to ContentViewController
            contentViewController.view.layer.shadowOpacity = 1
            contentViewController.view.layer.shadowRadius = 6
            
            contentView.addSubview(contentViewController.view)
            var vc = contentViewController.childViewControllers.first as? MenuContentViewControllerProtocol
            vc?.delegate = self
            
            contentViewController.didMove(toParentViewController: self)
            
            // After the content view is selected, the menu view disappears automatically
            UIView.animate(withDuration: 0.3) {
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let storyboard = UIStoryboard(name: "HamburgerMenu", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "HamburgerMenuView") as! HamburgerMenuController
        menuViewController.hamburgerViewController = self
        self.menuViewController = menuViewController

    }
}

extension HamburgerViewController: MenuButtonPressDelegate {
    func onMenuButtonPress() {
        print("Menu pressed")
        UIView.animate(withDuration: 0.3, animations: {
            self.leftMarginConstraint.constant = self.view.frame.size.width - 50
        })
    }
}
