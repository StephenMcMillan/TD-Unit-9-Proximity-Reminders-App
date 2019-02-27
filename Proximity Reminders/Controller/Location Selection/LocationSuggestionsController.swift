//
//  LocationSuggestionsController.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit
import MapKit

class LocationSuggestionsController: UITableViewController {
    
    // Assists with auto-complete suggestions of nearby locations
    private let searchCompleter = MKLocalSearchCompleter()
    
    // MKLocalSearchCompleter will return an array of completion objects that we will use as the datasource for the tableview.
    var searchCompleterResults = [MKLocalSearchCompletion]()
    
    convenience init() {
        self.init(style: .plain)
        searchCompleter.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BasicDetailCell.self, forCellReuseIdentifier: BasicDetailCell.reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCompleterResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BasicDetailCell.reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = searchCompleterResults[indexPath.row].title
        cell.detailTextLabel?.text = searchCompleterResults[indexPath.row].subtitle
        
        return cell
    }
}

// MARK: Updates the the Search Bar Text
extension LocationSuggestionsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        // The text from the search bar needs to be passed through to the search completer query
        searchCompleter.queryFragment = searchText
    }
}

// MARK: MKLocalSearchCompleter Delegate
extension LocationSuggestionsController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // When the local search completer gets results, assign them to a local property that is used to populate the table view then reload that table view to show the results.
        searchCompleterResults = completer.results
        tableView.reloadData()
    }
    
    // There is an optional error delegate method but it returns errors randomly... :(
}
