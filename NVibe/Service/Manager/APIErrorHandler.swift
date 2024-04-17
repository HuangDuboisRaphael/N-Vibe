//
//  APIErrorHandler.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

/// Non-exhaustive list of API errors.
enum APIErrorHandler: Error, Equatable {
    case noConnection
    case badUrl
    case badRequest
    case transportError
    case unauthorized
    case notFound
    case requestTimeout
    case tooManyRequests
    case serverError
    case encodingError
    case decodingError
    case pipelineError
    case http(statusCode: Int)
}

/// To return the corresponding string for each case of APIErrorHandler.
extension APIErrorHandler: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noConnection:
            "Check your internet connection."
        case .badUrl, .notFound, .transportError, .requestTimeout, .encodingError, .decodingError, .serverError, .unauthorized, .tooManyRequests, .http, .badRequest, .pipelineError:
            "Contact administrators for further help."
        }
    }
}
