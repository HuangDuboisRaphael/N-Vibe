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
    var selectedPlacemarkStart: Placemark? { get set }
    var selectedPlacemarkArrival: Placemark? { get set }
    
    func getSingleResult(at indexPath: IndexPath) -> MKLocalSearchCompletion
    func getPlacemarkInformation(at indexPath: IndexPath, isSearchingArrival: Bool)
    func didSelectedPlacemarkToCloseView()
    func errorResultingClosingView()
    func removeCoordinator()
}

final class SearchLocationViewModel: SearchLocationViewModelRepresentable {
    /// SearchLocationViewModelRepresentable properties.
    var searchResults: [MKLocalSearchCompletion] = []
    var selectedPlacemarkStart: Placemark?
    var selectedPlacemarkArrival: Placemark?
    
    /// Depedencies and initialization.
    private let flowDelegate: SearchLocationCoordinatorFlowDelegate
    
    init(flowDelegate: SearchLocationCoordinatorFlowDelegate) {
        self.flowDelegate = flowDelegate
    }
    
    /// SearchLocationViewModelRepresentable methods.
    func getSingleResult(at indexPath: IndexPath) -> MKLocalSearchCompletion {
        searchResults[indexPath.row]
    }
    
    func getPlacemarkInformation(at indexPath: IndexPath, isSearchingArrival: Bool) {
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
            if isSearchingArrival {
                self.selectedPlacemarkArrival = (name: name, coordinate: coordinate)
            } else {
                self.selectedPlacemarkStart = (name: name, coordinate: coordinate)
            }
            self.flowDelegate.didSelectedPlacemarkToCloseView()
        }
    }
    
    func didSelectedPlacemarkToCloseView() {
        flowDelegate.didSelectedPlacemarkToCloseView()
    }
    
    func errorResultingClosingView() {
        flowDelegate.errorResultingClosingView()
    }
    
    func removeCoordinator() {
        flowDelegate.removeCoordinator()
    }
}
