//
//  HamburgerMenuController.swift
//  Film Locations
//
//  Created by Laura on 5/4/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import AFNetworking

class HamburgerMenuController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var menu = ["Map View", "List View", "Profile", "About", "Logout", "Login"]
    var symbols = ["map", "list", "profile", "about", "logout", "login"]
    var menuOptions: [MenuOption] = []
    
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = User.currentUser
        
        setupMenuOptions()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = tableView.frame.height / CGFloat(menu.count - 1)
        
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
        
        //tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        user = User.currentUser
        updateUI()
    }
    
    private func updateUI() {
        if user != nil && user?.screenname != "anonymous" {
            userNameLabel.text = user?.name
            userLocationLabel.text = user?.location
            
            if let profileImageURL = user?.profileUrl {
                profileImageView.setImageWith(profileImageURL)
            }
        }
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width/2
        profileImageView.layer.masksToBounds = true

        borderView.layer.cornerRadius = borderView.bounds.size.width/2
        borderView.layer.masksToBounds = true

        tableView.backgroundColor = UIColor.black
        tableView.alpha = 0.9

        headerView.backgroundColor = UIColor.fl_secondary
        headerView.tintColor = UIColor.white
    }
    
    private func setupMenuOptions() {
        menuOptions.removeAll()
        for index in 0..<menu.count {
            let menuOption = MenuOption(symbol: symbols[index], text: menu[index])
            menuOptions.append(menuOption)
        }
    }
    
}

extension HamburgerMenuController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Not all the elements from menuOptions are being displayed, we display eighter login or logout
        return menuOptions.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! HamburgerMenuCell
        cell.option = menuOptions[indexPath.row]
        
        if (indexPath.row == 4) {
            let isUserLoggedIn = (User._currentUser == nil || User._currentUser?.screenname == "anonymous") ? false : true
            cell.option = isUserLoggedIn ? menuOptions[indexPath.row] : menuOptions[indexPath.row + 1]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.fl_secondary
        tableView.cellForRow(at: indexPath)?.selectedBackgroundView = backgroundView
        
        tableView.deselectRow(at: indexPath, animated: true)    
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.black
        cell.contentView.alpha = 0.9

        cell.tintColor = UIColor.white
    }
}
