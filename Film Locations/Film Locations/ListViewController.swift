//
//  ListViewController.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var firebaseMovies: [FirebaseMovie] = []
    
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self

        // set cell's dimentions
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        firebaseMovies = InternalConfiguration.loadData()
        movies = mapFirebaseMoviesToMovies()
    }
    
    private func mapFirebaseMoviesToMovies() -> [Movie] {
        var mappedObjects: [String: Movie] = [:]
        var locations: [Location] = []
        var allMovies: [Movie] = []
        
        if !firebaseMovies.isEmpty {

            for (_, movie) in firebaseMovies.enumerated() {

                if mappedObjects[movie.title] == nil {
            
                    locations.append(Location(address: movie.address))
                    mappedObjects[movie.title] = Movie(title: movie.title, releaseYear: movie.releaseYear, posterImageURL: movie.posterImageURL, locations: locations, isExpanded: false)
                }
                else {
                    mappedObjects[movie.title]?.locations.append(Location(address: movie.address))
                }
             }
         }
        
        for (_, movie) in mappedObjects.enumerated() {
            allMovies.append(movie.value)
        }
        
        return allMovies
    }
    
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies[section].isExpanded ? movies[section].numberOfRows + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if indexPath.row == 0 {
            // display movie locations
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? ListViewCell
            movieCell?.movie = movies[indexPath.section]
            
            cell = movieCell
        }
        else {
            // display movie poster
            cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) 
            cell.textLabel?.text = movies[indexPath.section].locations[indexPath.row - 1].address
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let selectedMovieCell = tableView.cellForRow(at: indexPath) as? ListViewCell {
            // whatever
            selectedMovieCell.movie?.isExpanded = !((selectedMovieCell.movie?.isExpanded)!)
            
            tableView.reloadData()
        }
        else {
            // show new locations details screen
            // let selectedLocationCell = tableView.cellForRow(at: indexPath)
        }
    }
}
