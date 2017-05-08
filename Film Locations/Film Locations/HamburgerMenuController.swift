//
//  HamburgerMenuController.swift
//  Film Locations
//
//  Created by Laura on 5/4/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class HamburgerMenuController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var menu = ["Map View", "List View", "Profile", "About", "Logout"]
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 70
//        tableView.rowHeight = tableView.frame.height / CGFloat(menu.count)
        
        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil)
        let mapNavigationController = mapStoryBoard.instantiateViewController(withIdentifier: "MapNavigationController")
        
        let listStoryBoard = UIStoryboard(name: "List", bundle: nil)
        let listNavigationController = listStoryBoard.instantiateViewController(withIdentifier: "ListNavigationController")

        let profileStoryBoard = UIStoryboard(name: "Profile", bundle: nil)
        let profileNavigationController = profileStoryBoard.instantiateViewController(withIdentifier: "ProfileNavigationController")
        
        let aboutStoryBoard = UIStoryboard(name: "About", bundle: nil)
        let aboutNavigationController = aboutStoryBoard.instantiateViewController(withIdentifier: "AboutNavigationController")
        
        let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        let loginNavigationController = loginStoryBoard.instantiateViewController(withIdentifier: "Login")
        
        viewControllers.append(mapNavigationController)
        viewControllers.append(listNavigationController)
        viewControllers.append(profileNavigationController)
        viewControllers.append(aboutNavigationController)
        viewControllers.append(loginNavigationController)
        
        // setup the screen displayed after launching
        hamburgerViewController.contentViewController = mapNavigationController
    }

}

extension HamburgerMenuController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = menu[indexPath.row]
        
        if (indexPath.row == 4) {
            if (User._currentUser == nil || User._currentUser?.screenname == "anonymous") {
                cell.textLabel?.text = "Login"
            } else {
                cell.textLabel?.text = "Logout"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }
}
