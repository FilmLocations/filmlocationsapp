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
    
    var locations: [FilmLocation] = []
    var filteredLocationsGroupedByAddress: [FilmListViewItem] = []
    var locationsGroupedByAddress: [FilmListViewItem] = []
    
    var isSearchActive = false
    let search = UISearchBar()
    let dateFormatter = DateFormatter()
    
    var delegate: MenuButtonPressDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.backgroundColor = UIColor.fl_primary
        tableView.dataSource = self
        tableView.delegate = self

        // set cell's dimensions
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
  
        Database.shared.getAllLocations { locations in
            self.locations = locations
            self.groupByLocation(locations: locations)
            self.tableView.reloadData()
        }
        
        setupSearchBar()
        
        dateFormatter.dateFormat = "YYYY-MM-DD"
    }
    
    func groupByLocation(locations: [FilmLocation]) {
    
        locationsGroupedByAddress.removeAll()
        
        for location in locations {

            if let item = locationsGroupedByAddress.index(where: {$0.tmdbId == location.tmdbId}) {
                locationsGroupedByAddress[item].addresses.append(location.address)
            } else {
                locationsGroupedByAddress.append(FilmListViewItem(location: location))
            }
        }

        locationsGroupedByAddress = sortListByReleaseDate(locations: locationsGroupedByAddress)
        
        filteredLocationsGroupedByAddress = locationsGroupedByAddress
    }
    
    @IBAction func onMenuPress(_ sender: UIBarButtonItem) {
        search.resignFirstResponder()
        delegate?.onMenuButtonPress()
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = search
        search.placeholder = "Search Films"
        search.sizeToFit()
        search.keyboardAppearance = .dark
        search.tintColor = UIColor.fl_secondary
        search.delegate = self
    }

    
    private func sortListByReleaseDate(locations: [FilmListViewItem]) -> [FilmListViewItem] {
        
        return locations.sorted(by: { return $0.releaseYear > $1.releaseYear })
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
        
        if indexPath.row == 0 {
            // display movie info
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! ListViewCell
            movieCell.movie = filteredLocationsGroupedByAddress[indexPath.section]
            
            return movieCell
        }
        else {
            // display address
            let listCell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            listCell.textLabel?.text = filteredLocationsGroupedByAddress[indexPath.section].addresses[indexPath.row-1]
            listCell.textLabel?.textColor = UIColor.white
            listCell.backgroundColor = UIColor.fl_primary
            
            return listCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (search.isFirstResponder) {
            search.resignFirstResponder()
            return
        }
        
        if delegate?.isSideMenuOpen() ?? false {
            delegate?.onMenuButtonPress()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.row == 0 {
            
            // while expanding, move selected movie on top of the table
            if !filteredLocationsGroupedByAddress[indexPath.section].isExpanded {
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
            }

            filteredLocationsGroupedByAddress[indexPath.section].isExpanded = !filteredLocationsGroupedByAddress[indexPath.section].isExpanded
            
            tableView.reloadData()
            //tableView.reloadSections(IndexSet(integer: indexPath.section), with: .bottom)
        }
        else {

            // Address tap - open details page
            let filmDetailsStoryBoard = UIStoryboard(name: "FilmDetails", bundle: nil)

            let selectedLocationCell = tableView.cellForRow(at: indexPath)
            
            if let detailsViewController = filmDetailsStoryBoard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController {
                
                if let selectedLocation = locations.first(where: { $0.tmdbId == filteredLocationsGroupedByAddress[indexPath.section].tmdbId
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
        searchBar.placeholder = ""

        guard delegate?.isSideMenuOpen() == false else {
            delegate?.onMenuButtonPress()
            return true
        }
        return true
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.placeholder = "Search Films"
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearchActive = searchText != ""
        filteredLocationsGroupedByAddress = isSearchActive ? locationsGroupedByAddress.filter{$0.title.localizedCaseInsensitiveContains(searchText) || String($0.releaseYear).contains(searchText)} : locationsGroupedByAddress
        tableView.reloadData()
    }
}
