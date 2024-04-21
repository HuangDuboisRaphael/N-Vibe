//
//  SearchLocationViewModel.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import Foundation
import MapKit

protocol SearchLocationViewModelRepresentable: AnyObject {
    var searchResults: [MKLocalSearchCompletion] { get set }
    var selectedOrigin: (name: String, coordinate: CLLocationCoordinate2D)? { get set }
    var selectedDestination: (name: String, coordinate: CLLocationCoordinate2D)? { get set }
    
    func getSingleResult(at indexPath: IndexPath) -> MKLocalSearchCompletion
    func getDestinationInformation(at indexPath: IndexPath, isSearchingADestination: Bool)
    func closeView()
}

final class SearchLocationViewModel: SearchLocationViewModelRepresentable {
    var searchResults: [MKLocalSearchCompletion] = []
    var selectedOrigin: (name: String, coordinate: CLLocationCoordinate2D)?
    var selectedDestination: (name: String, coordinate: CLLocationCoordinate2D)?
    
    /// Depedencies and initialization.
    private let flowDelegate: SearchLocationCoordinatorFlowDelegate
    
    init(flowDelegate: SearchLocationCoordinatorFlowDelegate) {
        self.flowDelegate = flowDelegate
    }
    
    func getSingleResult(at indexPath: IndexPath) -> MKLocalSearchCompletion {
        searchResults[indexPath.row]
    }
    
    func getDestinationInformation(at indexPath: IndexPath, isSearchingADestination: Bool) {
        let singleResult = getSingleResult(at: indexPath)
        let searchRequest = MKLocalSearch.Request(completion: singleResult)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, _) in
            guard let self = self else { return }
            guard
                let coordinate = response?.mapItems[0].placemark.coordinate,
                let name = response?.mapItems[0].name else {
                return
            }
            if isSearchingADestination {
                self.selectedDestination = (name: name, coordinate: coordinate)
            } else {
                self.selectedOrigin = (name: name, coordinate: coordinate)
            }
            self.flowDelegate.closeView()
        }
    }
    
    func closeView() {
        flowDelegate.closeView()
    }
}
