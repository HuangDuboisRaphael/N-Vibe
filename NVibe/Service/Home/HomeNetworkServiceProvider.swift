//
//  HomeNetworkServiceProvider.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation
import Combine

enum HomeNetworkServiceProvider {
    case retrieveDirectionsForWalking
}

extension HomeNetworkServiceProvider {
    func buildRequest(with coordinates: String) -> AnyPublisher<URLRequest, APIErrorHandler> {
        switch self {
        case .retrieveDirectionsForWalking:
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "geometries", value: "geojson"),
                URLQueryItem(name: "access_token", value: Configuration.apiKey)
            ]
            return URLRequestBuilder(with: API.baseUrl)
                .set(path: API.Path.walking + coordinates)
                .set(queryItems: queryItems)
                .build()
        }
    }
}
