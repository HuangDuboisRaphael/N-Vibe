//
//  HomeViewModel.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import Foundation
import Combine
import CoreLocation
import MapboxDirections
import MapboxCoreNavigation

protocol HomeViewModelRepresentable: LoadableObject {
    var selectedDestination: (name: String, coordinate: CLLocationCoordinate2D)? { get set }
    var routeOptions: NavigationRouteOptions { get }
    var routeResponse: RouteResponse? { get }
    var route: Route? { get }
    var didCalculateRoute: (() -> Void)? { get set }
    
    func calculateRoute()
    func displaySearchLocationView()
}

final class HomeViewModel: HomeViewModelRepresentable {
    private var origin: Waypoint {
        Waypoint(coordinate: LocationManager.shared.currentLocation.coordinate, coordinateAccuracy: -1, name: "Start")
    }
    
    private var destination: Waypoint {
        Waypoint(coordinate: self.selectedDestination?.coordinate ?? CLLocationCoordinate2D(), coordinateAccuracy: -1, name: "Finish")
    }
    
    var routeOptions: NavigationRouteOptions {
        NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
    }
    var didCalculateRoute: (() -> Void)?
    var routeResponse: RouteResponse?
    var route: Route?
    
    var loadingState: LoadingState = .idle {
        didSet {
            switch loadingState {
            case .idle:
                break
            case .loading:
                break
            case .failed(let error):
                print(error)
            case .loaded:
                didCalculateRoute?()
            }
        }
    }
    
    var selectedDestination: (name: String, coordinate: CLLocationCoordinate2D)?
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func calculateRoute() {
        self.loadingState = .loading
        homeDirectionService.calculateRoute(routeOptions)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [unowned self] response in
                self.routeResponse = response
                self.route = routeResponse?.routes?.first
                self.loadingState = .loaded
            }
            .store(in: &cancellables)
    }
    
    func displaySearchLocationView() {
        flowDelegate.displaySearchLocationView()
    }
}
