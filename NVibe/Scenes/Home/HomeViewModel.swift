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
    var origin: Waypoint { get }
    var destination: Waypoint { get }
    var selectedDestination: (name: String, coordinate: CLLocationCoordinate2D)? { get set }
    var routeOptions: NavigationRouteOptions { get }
    var routeResponse: RouteResponse? { get }
    var direction: Direction? { get }
    var didSelectDestination: (() -> Void)? { get set }
    var didCalculateRoute: (() -> Void)? { get set }
    var indicationLabelText: String { get }
    var lineCoordinates: [CLLocationCoordinate2D] { get }
    
    func calculateRouteWithApi()
    func calculateRoute()
    func displaySearchLocationView()
    func displayMapboxNavigation()
}

final class HomeViewModel: HomeViewModelRepresentable {
    var origin: Waypoint {
        Waypoint(coordinate: LocationManager.shared.currentLocation.coordinate, coordinateAccuracy: -1, name: "Start")
    }
    
    var destination: Waypoint {
        Waypoint(coordinate: self.selectedDestination?.coordinate ?? CLLocationCoordinate2D(), coordinateAccuracy: -1, name: "Finish")
    }
    
    var routeOptions: NavigationRouteOptions {
        NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
    }
    var didSelectDestination: (() -> Void)?
    var didCalculateRoute: (() -> Void)?
    var routeResponse: RouteResponse?
    
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
    var direction: Direction?
    var indicationLabelText: String {
        guard let direction = direction else { return "" }
        return "\(direction.routes[0].duration.convertDurationToText()) - \(direction.routes[0].distance.convertDistanceToText())"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var coordinatesToQuery: String {
        guard let selectedDestination = selectedDestination else { return "" }
        return "\(LocationManager.shared.currentLocation.coordinate.longitude),\(LocationManager.shared.currentLocation.coordinate.latitude);\(selectedDestination.coordinate.longitude),\(selectedDestination.coordinate.latitude)"
    }
    var lineCoordinates: [CLLocationCoordinate2D] {
        guard let direction = direction else { return []}
        let coordinates: [CLLocationCoordinate2D] = (direction.routes[0].geometry.coordinates.map { coordinatePair in
            CLLocationCoordinate2DMake(coordinatePair[1], coordinatePair[0])
        })
        return coordinates
    }
    
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
    
    func calculateRouteWithApi() {
        homeNetworkService.retrieveDirectionsForWalking(with: coordinatesToQuery)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { response in
                print(response)
                self.direction = response
                self.loadingState = .loaded
            }
            .store(in: &cancellables)
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
                self.loadingState = .loaded
            }
            .store(in: &cancellables)
    }
    
    func displaySearchLocationView() {
        flowDelegate.displaySearchLocationView()
    }
    
    func displayMapboxNavigation() {
        flowDelegate.displayMapboxNavigation()
    }
}
