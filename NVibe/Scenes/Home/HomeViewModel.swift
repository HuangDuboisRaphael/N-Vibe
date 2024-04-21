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
    var selectedOrigin: (name: String, coordinate: CLLocationCoordinate2D)? { get set }
    var selectedDestination: (name: String, coordinate: CLLocationCoordinate2D)? { get set }
    var routeOptions: NavigationRouteOptions { get }
    var routeResponse: RouteResponse? { get set }
    var direction: Direction? { get }
    var isLoadingBackgroundTasks: (() -> Void)? { get set }
    var didSelectFirstDestination: (() -> Void)? { get set }
    var didSelectNewOrigin: (() -> Void)? { get set }
    var didSelectNewDestination: (() -> Void)? { get set }
    var didCalculateRoute: (() -> Void)? { get set }
    var indicationLabelText: String { get }
    var lineCoordinates: [CLLocationCoordinate2D] { get }
    
    func calculateRouteWithApi()
    func tryDisplayingMapboxNavigation()
    func displaySearchLocationView(forDestination: Bool)
}

final class HomeViewModel: HomeViewModelRepresentable {
    var isLoadingBackgroundTasks: (() -> Void)?
    
    var selectedOrigin: (name: String, coordinate: CLLocationCoordinate2D)?
    
    var didSelectNewOrigin: (() -> Void)?
    
    var didSelectNewDestination: (() -> Void)?
    
    private var origin: Waypoint {
        Waypoint(coordinate: self.selectedOrigin?.coordinate ?? LocationManager.shared.currentLocation.coordinate, coordinateAccuracy: -1, name: "Start")
    }
    
    private var destination: Waypoint {
        Waypoint(coordinate: self.selectedDestination?.coordinate ?? CLLocationCoordinate2D(), coordinateAccuracy: -1, name: "Finish")
    }
    
    var routeOptions: NavigationRouteOptions {
        NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
    }
    var didSelectFirstDestination: (() -> Void)?
    var didCalculateRoute: (() -> Void)?
    var routeResponse: RouteResponse?
    
    var loadingState: LoadingState = .idle {
        didSet {
            switch loadingState {
            case .idle:
                break
            case .loading:
                isLoadingBackgroundTasks?()
            case .failed(let error):
                print(error)
            case .loaded:
                cancellables.forEach({ $0.cancel() })
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
        return selectedOrigin == nil ? "\(LocationManager.shared.currentLocation.coordinate.longitude),\(LocationManager.shared.currentLocation.coordinate.latitude);\(selectedDestination.coordinate.longitude),\(selectedDestination.coordinate.latitude)" :
            "\(selectedOrigin!.coordinate.longitude),\(selectedOrigin!.coordinate.latitude);\(selectedDestination.coordinate.longitude),\(selectedDestination.coordinate.latitude)"
    }
    var lineCoordinates: [CLLocationCoordinate2D] {
        guard let direction = direction else { return [] }
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
        loadingState = .loading
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
                self.direction = response
                self.loadingState = .loaded
            }
            .store(in: &cancellables)
    }
    
    func tryDisplayingMapboxNavigation() {
        loadingState = .loading
        flowDelegate.navigationViewController?.navigationService.router.finishRouting()
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
                flowDelegate.displayMapboxNavigation()
                self.loadingState = .loaded
            }
            .store(in: &cancellables)
    }
    
    func displaySearchLocationView(forDestination: Bool) {
        flowDelegate.displaySearchLocationView(forDestination: forDestination)
    }
}
