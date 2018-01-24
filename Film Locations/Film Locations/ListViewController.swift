//
//  ListViewController.swift
//  Film Locations
//
//  Created by Laura on 4/28/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit

protocol MenuButtonPressDelegate {
    func isSideMenuOpen() -> Bool
    func onMenuButtonPress()
}

class ListViewController: UIViewController, MenuContentViewControllerProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filtersView: UIView!
    @IBOutlet weak var newMoviesFilterLabel: UILabel!
    @IBOutlet weak var popularFilterLabel: UILabel!
    @IBOutlet weak var mostVisitedFilterLabel: UILabel!
    @IBOutlet weak var favoritesFilterLabel: UILabel!
    
    var locations: [FilmLocation] = []
    var filteredLocationsGroupedByAddress: [FilmListViewItem] = []
    var locationsGroupedByAddress: [FilmListViewItem] = []
    
    var isSearchActive = false
    let search = UISearchBar()
    let dateFormatter = DateFormatter()
    
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
                filteredLocationsGroupedByAddress = sortMoviesByReleaseDates()
            case .Popular:
                popularFilterLabel.isHidden = false
                filteredLocationsGroupedByAddress = sortMoviesByPopularity()
            case .MostVisited:
                mostVisitedFilterLabel.isHidden = false
                filteredLocationsGroupedByAddress = filteredLocationsGroupedByAddress.sorted{$0.addresses.count > $1.addresses.count}
            case .Favorites:
                favoritesFilterLabel.isHidden = false
                filteredLocationsGroupedByAddress = filteredLocationsGroupedByAddress.sorted{$0.releaseYear > $1.releaseYear}
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

        // set cell's dimensions
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
  
        Database.sharedInstance.getAllLocations { locations in
            self.locations = locations
            self.activeFilter = self.getPersistantActiveFilter()
            self.groupByLocation(locations: locations)
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
        
        dateFormatter.dateFormat = "YYYY-MM-DD"
    }
    
    func groupByLocation(locations: [FilmLocation]) {
        
        for location in locations {
         
            if let item = filteredLocationsGroupedByAddress.index(where: {$0.id == location.id}) {
                filteredLocationsGroupedByAddress[item].addresses.append(location.address)
            } else {
                filteredLocationsGroupedByAddress.append(FilmListViewItem(location: location))
            }
        }
        
        locationsGroupedByAddress = filteredLocationsGroupedByAddress
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
    
    private func sortMoviesByReleaseDates() -> [FilmListViewItem] {
        filteredLocationsGroupedByAddress.sort { (movie1, movie2) -> Bool in
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
        return filteredLocationsGroupedByAddress
    }
    
    private func sortMoviesByPopularity() -> [FilmListViewItem] {
        filteredLocationsGroupedByAddress.sort { (movie1, movie2) -> Bool in
            guard let popularity1 = movie1.popularity else {
                return false
            }

            guard let popularity2 = movie2.popularity else {
                return false
            }
            return popularity1 > popularity2
        }
        return filteredLocationsGroupedByAddress
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredLocationsGroupedByAddress.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocationsGroupedByAddress[section].isExpanded ? filteredLocationsGroupedByAddress[section].addresses.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if indexPath.row == 0 {
            // display movie info
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? ListViewCell
            movieCell?.movie = filteredLocationsGroupedByAddress[indexPath.section]
            
            cell = movieCell
        }
        else {
            // display address
            cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            cell.textLabel?.text = filteredLocationsGroupedByAddress[indexPath.section].addresses[indexPath.row-1]
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.row == 0 {
            
            // while expanding, move selected movie on top of the table
            if filteredLocationsGroupedByAddress[indexPath.section].isExpanded {
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            }

            filteredLocationsGroupedByAddress[indexPath.section].isExpanded = !filteredLocationsGroupedByAddress[indexPath.section].isExpanded
            
            tableView.reloadData()
            //tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
        else {
            // Address tap - open details page
            let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)

            let selectedLocationCell = tableView.cellForRow(at: indexPath)
            
            if let detailsViewController = filmDetailsStoryBoard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController {
            
                if let selectedLocation = locations.first(where: { $0.id == filteredLocationsGroupedByAddress[indexPath.section].id
                    && $0.address == selectedLocationCell?.textLabel?.text
                }) {
                    detailsViewController.location = selectedLocation
                }
                
                let navigationController = UINavigationController(rootViewController: detailsViewController)
                navigationController.setViewControllers([detailsViewController], animated: false)
                
                present(navigationController, animated: true, completion: nil)
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
        filteredLocationsGroupedByAddress = locationsGroupedByAddress
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearchActive = searchText != ""
        filteredLocationsGroupedByAddress = isSearchActive ? locationsGroupedByAddress.filter{$0.title.localizedCaseInsensitiveContains(searchText) || $0.releaseYear.contains(searchText)} : locationsGroupedByAddress
        tableView.reloadData()
    }
}
