//
//  ViewController.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/23/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var navController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: If user was last on Map View, display map view otherwise display listview
        
        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil)
        let mapViewController = mapStoryBoard.instantiateViewController(withIdentifier: "MapsView") as? MapViewController
//        self.navController?.setViewControllers([mapViewController!], animated: false)
        
        let listStoryBoard = UIStoryboard(name: "List", bundle: nil)
        let listViewController = listStoryBoard.instantiateViewController(withIdentifier: "List") as? ListViewController
//        self.navController?.setViewControllers([listViewController!], animated: false)
        
        let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)
        let detailsViewController = filmDetailsStoryBoard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController
//        self.navController?.setViewControllers([detailsViewController!], animated: false)
        
        let menu = MenuViewController(nibName: "MenuViewController", bundle: nil)
        self.navController?.setViewControllers([menu], animated: false)
        menu.firstViewController = mapViewController
        menu.secondViewController = listViewController
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = menu
        window.makeKeyAndVisible()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "MainSegue":
            self.navController = segue.destination as? UINavigationController
            print("")
        default:
            print("")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
