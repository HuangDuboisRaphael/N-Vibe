//
//  Configuration.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

enum Environment {
    case development
    case staging
    case production
}

enum API {
    static var baseUrl: String {
        "https://api.mapbox.com/directions/v5/mapbox"
    }
    
    enum Path {
        static var walking: String {
            "/walking/"
        }
    }
}

enum Configuration {
    enum Keys {
        static let apiKey = "API_KEY"
    }
}

extension Configuration {
    static let apiKey: String = {
        guard let apiKey = Configuration.infoDictionary[Keys.apiKey] as? String else {
            fatalError("API key not set in plist.")
        }
        return apiKey
    }()
    
    private static let infoDictionary: [String: Any] = {
        guard let dictionary = Bundle.main.infoDictionary else {
            fatalError("plist file not found.")
        }
        return dictionary
    }()
}
