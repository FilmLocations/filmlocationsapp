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
        
//        let mapStoryBoard = UIStoryboard(name: "Map", bundle: nil)
//        self.navController?.setViewControllers([mapStoryBoard.instantiateInitialViewController()!], animated: false)
        
//        let listStoryBoard = UIStoryboard(name: "List", bundle: nil)
//        let viewController = listStoryBoard.instantiateViewController(withIdentifier: "List") as? ListViewController
//        self.navController?.setViewControllers([viewController!], animated: false)
        
        //let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)
        //self.navController?.setViewControllers([filmDetailsStoryBoard.instantiateInitialViewController()!], animated: false)
        
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
