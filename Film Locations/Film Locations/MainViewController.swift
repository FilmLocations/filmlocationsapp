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
                
        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil)
        let mapViewController = mapStoryBoard.instantiateViewController(withIdentifier: "MapsView") as? MapViewController
        
        let listStoryBoard = UIStoryboard(name: "List", bundle: nil)
        let listViewController = listStoryBoard.instantiateViewController(withIdentifier: "List") as? ListViewController
                
        let menu = MenuViewController(nibName: "MenuViewController", bundle: nil)
        navController?.setViewControllers([menu], animated: false)
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
            navController = segue.destination as? UINavigationController
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
