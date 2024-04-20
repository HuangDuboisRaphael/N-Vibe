//
//  HomeNetworkService.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation
import Combine

protocol HomeNetworkServiceInterface: AnyObject {
    func retrieveDirectionsForWalking(with coordinates: String) -> AnyPublisher<Direction, APIErrorHandler>
}

final class HomeNetworkService: HomeNetworkServiceInterface {
    private let networkManager: APIRequestManagerInterface
    
    init(networkManager: APIRequestManagerInterface = APIRequestManager()) {
        self.networkManager = networkManager
    }
    
    func retrieveDirectionsForWalking(with coordinates: String) -> AnyPublisher<Direction, APIErrorHandler> {
        HomeNetworkServiceProvider.retrieveDirectionsForWalking.buildRequest(with: coordinates)
            .flatMap { [unowned self] request -> AnyPublisher<Direction, APIErrorHandler> in
                print(request)
                return self.networkManager.performRequest(request, decodingType: Direction.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
