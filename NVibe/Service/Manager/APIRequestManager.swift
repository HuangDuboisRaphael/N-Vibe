//
//  APIRequestManager.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation
import Combine

/// Protocol to adopt for better abstraction and testability.
protocol APIRequestManagerInterface: AnyObject {
    func performRequest<T: Decodable>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, APIErrorHandler>
}

final class APIRequestManager: APIRequestManagerInterface {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Generic method for JSON URLSession requests.
    func performRequest<T: Decodable>(_ request: URLRequest, decodingType: T.Type) -> AnyPublisher<T, APIErrorHandler> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { [unowned self] output -> Data in
                try self.validateResponse(output.response)
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error -> APIErrorHandler in
                if let error = error as? APIErrorHandler {
                    return error
                }
                return .decodingError
            })
            .eraseToAnyPublisher()

    }
}

/// To handle HTTPURLResponse errors.
private extension APIRequestManager {
    func validateResponse(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw APIErrorHandler.badRequest
        }
        switch response.statusCode {
        case 200..<300:
            return
        case 400:
            throw APIErrorHandler.badRequest
        case 401:
            throw APIErrorHandler.unauthorized
        case 404:
            throw APIErrorHandler.notFound
        case 408:
            throw APIErrorHandler.requestTimeout
        case 429:
            throw APIErrorHandler.tooManyRequests
        case 500:
            throw APIErrorHandler.serverError
        default:
            throw APIErrorHandler.http(statusCode: response.statusCode)
        }
    }
}
