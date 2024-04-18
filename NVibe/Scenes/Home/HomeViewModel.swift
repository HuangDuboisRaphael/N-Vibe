//
//  HomeViewModel.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import Foundation

protocol HomeViewModelRepresentable: AnyObject {
    func displaySearchLocationView()
}

final class HomeViewModel: HomeViewModelRepresentable {
    /// Depedencies and initialization.
    private let flowDelegate: HomeCoordinatorFlowDelegate
    private let homeNetworkService: HomeNetworkServiceInterface
    private let homeDirectionService: HomeDirectionServiceInterface
    
    init(
        flowDelegate: HomeCoordinatorFlowDelegate,
        homeNetworkService: HomeNetworkServiceInterface = HomeNetworkService(),
        homeDirectionService: HomeDirectionService = HomeDirectionService()
    ) {
        self.flowDelegate = flowDelegate
        self.homeNetworkService = homeNetworkService
        self.homeDirectionService = homeDirectionService
    }
    
    func displaySearchLocationView() {
        flowDelegate.displaySearchLocationView()
    }
}
