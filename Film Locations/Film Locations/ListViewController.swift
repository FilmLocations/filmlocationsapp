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
    
    var movies: [Movie] = []
    var filteredMovies: [Movie] = []
    var isSearchActive = false
    let search = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self

        // set cell's dimentions
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        Database.sharedInstance.getAllFilms { (movies: [Movie]) in
            self.movies = movies
            self.filteredMovies = movies
            self.tableView.reloadData()
        }
        
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = search
        search.placeholder = "Search"
        search.sizeToFit()
        
        search.delegate = self
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies[section].isExpanded ? filteredMovies[section].numberOfRows + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if indexPath.row == 0 {
            // display movie locations
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? ListViewCell
            movieCell?.movie = filteredMovies[indexPath.section]
            
            cell = movieCell
        }
        else {
            // display movie poster
            cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) 
            cell.textLabel?.text = filteredMovies[indexPath.section].locations[indexPath.row - 1].address
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
            
            let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)
            let detailsViewController = filmDetailsStoryBoard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController

            if let detailsViewController = detailsViewController {
            
                detailsViewController.locationIndex = indexPath.row - 1
                detailsViewController.movie = filteredMovies[indexPath.section]
                
                let navigationController = UINavigationController(rootViewController: detailsViewController)
                navigationController.setViewControllers([detailsViewController], animated: false)
                
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}

extension ListViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        isSearchActive = false
        filteredMovies = movies
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearchActive = searchText != ""
        filteredMovies = isSearchActive ? movies.filter{$0.title.localizedCaseInsensitiveContains(searchText) || $0.releaseYear.contains(searchText)} : movies
        tableView.reloadData()
    }
}
