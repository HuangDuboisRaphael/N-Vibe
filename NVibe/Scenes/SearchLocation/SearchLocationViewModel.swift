//
//  SearchLocationViewModel.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import Foundation

protocol SearchLocationViewModelRepresentable: AnyObject {
    func closeView()
}

final class SearchLocationViewModel: SearchLocationViewModelRepresentable {
    /// Depedencies and initialization.
    private let flowDelegate: SearchLocationCoordinatorFlowDelegate
    
    init(flowDelegate: SearchLocationCoordinatorFlowDelegate) {
        self.flowDelegate = flowDelegate
    }
    
    func closeView() {
        flowDelegate.closeView()
    }
}
