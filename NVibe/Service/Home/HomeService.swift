//
//  HomeService.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation
import Combine

protocol HomeServiceInterface: AnyObject {
    func retrieveDirectionsForWalking() -> AnyPublisher<Direction, APIErrorHandler>
}

final class HomeService: HomeServiceInterface {
    private let networkManager: APIRequestManagerInterface
    private let locationManager: LocationManager
    
    init(networkManager: APIRequestManagerInterface = APIRequestManager(), locationManager: LocationManager = LocationManager.shared) {
        self.networkManager = networkManager
        self.locationManager = locationManager
    }
    
    func retrieveDirectionsForWalking() -> AnyPublisher<Direction, APIErrorHandler> {
        HomeServiceProvider.retrieveDirectionsForWalking.buildRequest()
            .flatMap { [unowned self] request -> AnyPublisher<Direction, APIErrorHandler> in
                print(request)
                return self.networkManager.performRequest(request, decodingType: Direction.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
