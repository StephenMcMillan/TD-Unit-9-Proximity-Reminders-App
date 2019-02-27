//
//  LocationSearchController.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchControllerDelegate: class {
    /// Alerts the delegate when the user selected a MKMapItem
    func userSelectedLocation(_ mapItem: MKMapItem)
}

class LocationSearchController: UITableViewController {
    
    // Results Table View Controller that will display the auto-completed list of locations based on the querys search
    private lazy var locationSuggestionsController: LocationSuggestionsController = {
        let locationSuggestionsController = LocationSuggestionsController()
        locationSuggestionsController.tableView.delegate = self // We want to handle table view taps here.
        return locationSuggestionsController
    }()
    
    // Manages the search bar and presents the search results controller when the user taps the search bar
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.locationSuggestionsController)
        // The Location Suggestions Controller will receive a callback when the search text chanegs
        searchController.searchResultsUpdater = self.locationSuggestionsController
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private var locations = [MKMapItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var localSearch: MKLocalSearch? {
        willSet {
            localSearch?.cancel()
        }
    }
    
    weak var delegate: LocationSearchControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(BasicDetailCell.self, forCellReuseIdentifier: BasicDetailCell.reuseIdentifier)
        
        // Assigns the search controller to the nav item and sets it to be visible at all times.
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        title = "Select a Location"
        definesPresentationContext = true
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(LocationSearchController.cancel))
        navigationItem.rightBarButtonItem = cancelBarButtonItem
    }
    
    
    // MARK: Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BasicDetailCell.reuseIdentifier, for: indexPath)
        
        let location = locations[indexPath.row]
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = location.placemark.title
        
        return cell
    }
    
    // MARK: Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == locationSuggestionsController.tableView {
            // If we selected an item in the suggestions table view then search for that suggestion
            let suggestedSearch = locationSuggestionsController.searchCompleterResults[indexPath.row]
            searchController.isActive = false // Finished with search controller
            searchController.searchBar.text = suggestedSearch.title // Maintain the search text for consistency
            search(using: suggestedSearch) // Search for the suggestion
        } else {
            // The user selected a location from the results returned from our MKLocalSearch
            delegate?.userSelectedLocation(locations[indexPath.row])
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Local Search Methods
    
    // This search method will be used if the user selects one of the search suggestions
    private func search(using suggestedCompletion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: request)
    }
    
    // Users can press the search button without selection a suggestion. If this happens just search for their basic string
    private func search(for searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        search(using: request)
    }
    
    // This function is the common end point reached by either of the 2 above search functions and it actually searches using a request
    private func search(using request: MKLocalSearch.Request) {
        localSearch = MKLocalSearch(request: request)
        localSearch?.start() { [weak self] (response, error) in
            
            guard error == nil else {
                self?.displayAlert(for: error)
                return
            }
            
            self?.locations = response?.mapItems ?? []
        }
    }
    
    @objc func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension LocationSearchController: UISearchBarDelegate {
    // The user might search using their own text and ignore the suggestions, this method will handle that case.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        dismiss(animated: true, completion: nil)
        search(for: searchText)
    }
    
}
