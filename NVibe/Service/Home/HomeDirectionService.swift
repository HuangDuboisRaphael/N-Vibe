//
//  HomeDirectionService.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import Combine
import CoreLocation
import MapboxDirections
import MapboxCoreNavigation

protocol HomeDirectionServiceInterface {
    func calculateRoute(from originCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) -> AnyPublisher<RouteResponse, DirectionsError>
}

final class HomeDirectionService: HomeDirectionServiceInterface {
    init() {
        _ = LocationManager.shared
    }
    
    func calculateRoute(from originCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) -> AnyPublisher<RouteResponse, DirectionsError> {
        let origin = Waypoint(coordinate: originCoordinate, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destinationCoordinate, coordinateAccuracy: -1, name: "Finish")
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
        
        let publisher = PassthroughSubject<RouteResponse, DirectionsError>()
        Directions.shared.calculate(routeOptions) { (_, result) in
            switch result {
            case .failure(let error):
                publisher.send(completion: .failure(error))
            case .success(let response):
                guard let route = response.routes?.first else {
                    return
                }
                publisher.send(response)
            }
        }
        return publisher.eraseToAnyPublisher()
    }
}
