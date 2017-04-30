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
        tableView.rowHeight = 1
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        firebaseMovies = InternalConfiguration.moviesArray
        movies = mapFirebaseMoviesToMovies()
    }
    
    private func mapFirebaseMoviesToMovies() -> [Movie] {
        var mapObjects: [Movie] = []
        var locations: [Location] = []
        
        if !firebaseMovies.isEmpty {
            // add first location to the first movie's location list
            locations.append(Location(address: firebaseMovies[0].address, locationImageURL: firebaseMovies[0].locationImageURL))
            
            for (index, movie) in firebaseMovies.enumerated() {

                // if the last element wasn't reached
                if index != firebaseMovies.count - 1 {
                    
                    if movie.title == firebaseMovies[index+1].title {
                        locations.append(Location(address: firebaseMovies[index+1].address, locationImageURL: firebaseMovies[index+1].locationImageURL))
                    }
                    else {
                        // add first movie to the movie's list
                        mapObjects.append(Movie(title: firebaseMovies[index].title, releaseYear: firebaseMovies[index].releaseYear, posterImageURL: firebaseMovies[index].posterImageURL, locations: locations, isExpanded: false))

                        locations.removeAll()
                        
                        locations.append(Location(address: firebaseMovies[index+1].address, locationImageURL: firebaseMovies[index+1].locationImageURL))
                    }
                }
            }
            let lastMovieIndex = firebaseMovies.count - 1
            
            // add last element
            mapObjects.append(Movie(title: firebaseMovies[lastMovieIndex].title, releaseYear: firebaseMovies[lastMovieIndex].releaseYear, posterImageURL: firebaseMovies[lastMovieIndex].posterImageURL, locations: locations, isExpanded: false))
        }
        
        return mapObjects
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
            cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? ListViewCell
            cell.textLabel?.text = movies[indexPath.section].locations[indexPath.row].address
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedRow = tableView.cellForRow(at: indexPath) as? ListViewCell
        
        if (selectedRow?.movie?.isExpandable)! {
            selectedRow?.movie?.isExpanded = (selectedRow?.movie?.isExpanded)! ? false : true
            
            tableView.reloadData()
        }
    }
}
