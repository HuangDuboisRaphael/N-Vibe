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
    case notAuthorized
    case forbidden
    case profileNotFound
    case invalidInput
    case decodingError
    case encodingError
    case badUrl
    case unknownError(statusCode: Int)
}

/// To return the corresponding string for each case of APIErrorHandler.
extension APIErrorHandler: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noConnection:
            "Check your internet connection."
        case .notAuthorized:
            "Check the access token you used in the query."
        case .forbidden:
            "There may be an issue with your account."
        case .profileNotFound:
            "Profile not valid."
        case .invalidInput:
            "The given request was not valid. The message key of the response will hold an explanation of the invalid input."
        case .decodingError:
            "Error in decoding data."
        case .unknownError, .badUrl, .encodingError:
            "Unknown error."
        }
    }
}
