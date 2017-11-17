//
//  ListViewController.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

protocol MenuButtonPressDelegate {
    func onMenuButtonPress()
}

class ListViewController: UIViewController, MenuContentViewControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var newMoviesFilterLabel: UILabel!
    @IBOutlet weak var popularFilterLabel: UILabel!
    @IBOutlet weak var mostVisitedFilterLabel: UILabel!
    @IBOutlet weak var favoritesFilterLabel: UILabel!
    
    var movies: [FilmLocation] = []
    var filteredMovies: [FilmLocation] = []
    var isSearchActive = false
    let search = UISearchBar()
    
    var delegate: MenuButtonPressDelegate?
    
    private enum Filters: Int {
    
        case NewMovies = 0
        case Popular
        case MostVisited
        case Favorites
    }
    
    private var activeFilter: Filters = .NewMovies {
        willSet {
            if viewIfLoaded == nil {
                return
            }
            deactivateAllFilters()
            
            switch newValue {
            case .NewMovies:
                newMoviesFilterLabel.isHidden = false
                movies = sortMoviesByReleaseDates()
            case .Popular:
                popularFilterLabel.isHidden = false
                filteredMovies = sortMoviesByPopularity()
            case .MostVisited:
                mostVisitedFilterLabel.isHidden = false
                //TODO, not correct
                //filteredMovies = filteredMovies.sorted{$0.numberOfRows > $1.numberOfRows}
            case .Favorites:
                favoritesFilterLabel.isHidden = false
                filteredMovies = filteredMovies.sorted{$0.releaseYear > $1.releaseYear}
            }
            
            setPersistantActiveFilter(to: newValue.rawValue)
            
            // refresh the display
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self

        // set cell's dimentions
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        Database.sharedInstance.getAllFilms { (movies: [FilmLocation]) in
            self.movies = movies
            self.filteredMovies = movies
            self.activeFilter = self.getPersistantActiveFilter()
            self.tableView.reloadData()
        }
        
        setupSearchBar()
        
        filtersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onFilterTapGesture(_:))))

        filtersView.backgroundColor = UIColor.fl_secondary
        filtersView.tintColor = UIColor.black

        newMoviesFilterLabel.backgroundColor = UIColor.black
        popularFilterLabel.backgroundColor = UIColor.black
        mostVisitedFilterLabel.backgroundColor = UIColor.black
        favoritesFilterLabel.backgroundColor = UIColor.black
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        delegate?.onMenuButtonPress()
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = search
        search.placeholder = "Search"
        search.sizeToFit()
        
        search.delegate = self
    }
    
    private func getPersistantActiveFilter() -> Filters {
        return UserDefaults.standard.object(forKey: "ActiveFilter") as? Filters ?? .NewMovies
    }
    
    private func setPersistantActiveFilter(to value: Int) {
        UserDefaults.standard.set(value, forKey: "ActiveFilter")
        UserDefaults.standard.synchronize()
    }
    
    private func deactivateAllFilters() {
        newMoviesFilterLabel.isHidden = true
        popularFilterLabel.isHidden = true
        mostVisitedFilterLabel.isHidden = true
        favoritesFilterLabel.isHidden = true
    }
    
    @objc private func onFilterTapGesture(_ sender: UITapGestureRecognizer) {
        sender.numberOfTapsRequired = 1
        if sender.state == .ended
        {
            let tappedPosition = sender.location(in: filtersView)
            
            switch tappedPosition.x {
            case 8...43:
                activeFilter = .NewMovies
            case 76...135:
                activeFilter = .Popular
            case 168...263:
                activeFilter = .MostVisited
            case 297...367:
                activeFilter = .Favorites
            default:
                break
            }
        }
    }
    
    private func sortMoviesByReleaseDates() -> [FilmLocation] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        
        filteredMovies.sort { (movie1, movie2) -> Bool in
            guard let stringDate1 = movie1.date else {
                return false
            }
            
            guard let stringDate2 = movie2.date else {
                return false
            }
            
            let date1 = dateFormatter.date(from: stringDate1)
            let date2 = dateFormatter.date(from: stringDate2)
        
            return date1!.compare(date2!) == ComparisonResult.orderedDescending
        }
        return filteredMovies
    }
    
    private func sortMoviesByPopularity() -> [FilmLocation] {
        filteredMovies.sort { (movie1, movie2) -> Bool in
            guard let popularity1 = movie1.popularity else {
                return false
            }

            guard let popularity2 = movie2.popularity else {
                return false
            }
            return popularity1 > popularity2
        }
        return filteredMovies
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 //filteredMovies[section].isExpanded ? filteredMovies[section].numberOfRows + 1 : 1
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
            cell.textLabel?.text = filteredMovies[indexPath.section].address
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let selectedMovieCell = tableView.cellForRow(at: indexPath) as? ListViewCell {
            
            // while expanding, move selected movie on top of the table
//            if (selectedMovieCell.movie?.isExpanded)! == false {
//                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
//            }
//
//            selectedMovieCell.movie?.isExpanded = !((selectedMovieCell.movie?.isExpanded)!)
            
            tableView.reloadData()
        }
        else {
            // show new locations details screen
            
            let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)
            let detailsViewController = filmDetailsStoryBoard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController

            if let detailsViewController = detailsViewController {
            
                detailsViewController.movie = filteredMovies[indexPath.section]
                
                let navigationController = UINavigationController(rootViewController: detailsViewController)
                navigationController.setViewControllers([detailsViewController], animated: false)
                
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        
//        // Setup the CATransform3D structure
//        var rotation = CATransform3DIdentity
//        
//        rotation = CATransform3DMakeRotation(CGFloat((90.0 * .pi)/180), 0.0, 0.7, 0.4)
//        rotation.m34 = 1.0 / (-600)
//        
//        // Define the initial state (Before the animation)
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOffset = CGSize(width: 10, height: 10)
//        cell.alpha = 0
//        
//        cell.layer.transform = rotation
//        cell.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
//        
//        // Define the final state (After the animation) and commit the animation
//        UIView.beginAnimations("rotation", context: nil)
//        UIView.setAnimationDuration(0.8)
//        cell.layer.transform = CATransform3DIdentity
//        cell.alpha = 1
//        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
//        UIView.commitAnimations()
//        
//    }

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
