//
//  HomeDirectionService.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import Combine
import MapboxDirections

protocol HomeDirectionServiceInterface {
    func calculateRoute(_ routeOptions: RouteOptions) -> AnyPublisher<RouteResponse, DirectionsError>
}

final class HomeDirectionService: HomeDirectionServiceInterface {
    init() {
        // Call singleton and persit its reference.
        _ = LocationManager.shared
    }
    
    func calculateRoute(_ routeOptions: RouteOptions) -> AnyPublisher<RouteResponse, DirectionsError> {
        let publisher = PassthroughSubject<RouteResponse, DirectionsError>()
        Directions.shared.calculate(routeOptions) { (_, result) in
            switch result {
            case .failure(let error):
                publisher.send(completion: .failure(error))
            case .success(let response):
                publisher.send(response)
            }
        }
        return publisher.eraseToAnyPublisher()
    }
}
