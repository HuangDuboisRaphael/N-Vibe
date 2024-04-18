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
    func buildRequest() -> AnyPublisher<URLRequest, APIErrorHandler> {
        switch self {
        case .retrieveDirectionsForWalking:
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "access_token", value: Configuration.apiKey)
            ]
            let text = "2.33, 48.86;2.26, 48.91"
            return URLRequestBuilder(with: API.baseUrl)
                .set(path: API.Path.walking + text)
                .set(queryItems: queryItems)
                .build()
        }
    }
}
