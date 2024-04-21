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

typealias Placemark = (name: String, coordinate: CLLocationCoordinate2D)

protocol HomeViewModelRepresentable: LoadableObject {
    var selectedPlacemarkStart: Placemark? { get set }
    var selectedPlacemarkArrival: Placemark? { get set }
    var routeOptions: NavigationRouteOptions { get }
    var routeResponse: RouteResponse? { get set }
    var indicationLabelText: String { get }
    var lineCoordinates: [CLLocationCoordinate2D] { get }
    var isLoadingBackgroundTasks: (() -> Void)? { get set }
    var didSelectFirstArrival: (() -> Void)? { get set }
    var didSelectNewStart: (() -> Void)? { get set }
    var didSelectNewArrival: (() -> Void)? { get set }
    var didCalculateRoute: (() -> Void)? { get set }
    var didFailLoading: ((Error) -> Void)? { get set }
    
    func calculateRouteWithApi()
    func displayUserLocationAlert(title: String, message: String)
    func displayMapboxNavigation()
    func displaySearchLocationView(isSearchingArrival: Bool)
}

final class HomeViewModel: HomeViewModelRepresentable {
    // MARK: Private properties.
    private var startWaypoint: Waypoint {
        Waypoint(coordinate: self.selectedPlacemarkStart?.coordinate ?? LocationManager.shared.currentLocation.coordinate, coordinateAccuracy: -1, name: "Start")
    }

    private var arrivalWaypoint: Waypoint {
        Waypoint(coordinate: self.selectedPlacemarkArrival?.coordinate ?? CLLocationCoordinate2D(), coordinateAccuracy: -1, name: "Finish")
    }
    
    private var direction: Direction?
    private var cancellables = Set<AnyCancellable>()
    private var coordinatesToQuery: String {
        guard let arrival = selectedPlacemarkArrival else { return "" }
        return selectedPlacemarkStart == nil ? "\(LocationManager.shared.currentLocation.coordinate.longitude),\(LocationManager.shared.currentLocation.coordinate.latitude);\(arrival.coordinate.longitude),\(arrival.coordinate.latitude)" :
            "\(selectedPlacemarkStart!.coordinate.longitude),\(selectedPlacemarkStart!.coordinate.latitude);\(arrival.coordinate.longitude),\(arrival.coordinate.latitude)"
    }
    
    // MARK: HomeViewRepresentable properties.
    var selectedPlacemarkStart: Placemark?
    var selectedPlacemarkArrival: Placemark?
    var routeOptions: NavigationRouteOptions {
        NavigationRouteOptions(waypoints: [startWaypoint, arrivalWaypoint], profileIdentifier: .walking)
    }
    var routeResponse: RouteResponse?
    var isLoadingBackgroundTasks: (() -> Void)?
    var indicationLabelText: String {
        guard let direction = direction else { return "" }
        return "\(direction.routes[0].duration.convertDurationToText()) - \(direction.routes[0].distance.convertDistanceToText())"
    }
    var lineCoordinates: [CLLocationCoordinate2D] {
        guard let direction = direction else { return [] }
        let coordinates: [CLLocationCoordinate2D] = (direction.routes[0].geometry.coordinates.map { coordinatePair in
            CLLocationCoordinate2DMake(coordinatePair[1], coordinatePair[0])
        })
        return coordinates
    }
    var didSelectFirstArrival: (() -> Void)?
    var didSelectNewStart: (() -> Void)?
    var didSelectNewArrival: (() -> Void)?
    var didCalculateRoute: (() -> Void)?
    var didFailLoading: ((Error) -> Void)?
    
    // MARK: Loadable object conformance.
    var loadingState: LoadingState = .idle {
        didSet {
            switch loadingState {
            case .idle:
                break
            case .loading:
                isLoadingBackgroundTasks?()
            case .failed(let error):
                didFailLoading?(error)
            case .loaded:
                cancellables.forEach({ $0.cancel() })
                didCalculateRoute?()
            }
        }
    }
    
    // MARK: Depedencies and initialization.
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
    
    // MARK: HomeViewRepresentable methods.
    func calculateRouteWithApi() {
        loadingState = .loading
        guard NetworkUtils.isConnectedToInternet() else {
            self.loadingState = .failed(APIErrorHandler.noConnection)
            return
        }
        homeNetworkService.retrieveDirectionsForWalking(with: coordinatesToQuery)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.loadingState = .failed(error)
                }
            } receiveValue: { response in
                self.direction = response
                self.loadingState = .loaded
            }
            .store(in: &cancellables)
    }
    
    func displayUserLocationAlert(title: String, message: String) {
        flowDelegate.displayUserLocationAlert(title: title, message: message)
    }
    
    func displayMapboxNavigation() {
        loadingState = .loading
        guard NetworkUtils.isConnectedToInternet() else {
            self.loadingState = .failed(APIErrorHandler.noConnection)
            return
        }
        homeDirectionService.calculateRoute(routeOptions)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.loadingState = .failed(error)
                }
            } receiveValue: { [unowned self] response in
                self.routeResponse = response
                self.loadingState = .loaded
                flowDelegate.displayMapboxNavigation()
            }
            .store(in: &cancellables)
    }
    
    func displaySearchLocationView(isSearchingArrival: Bool) {
        flowDelegate.displaySearchLocationView(forArrival: isSearchingArrival)
    }
}
