//
//  RouteResponseAPI.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

struct RouteResponseAPI: Codable {
    let duration: Double
    let distance: Double
    let geometry: LineString
}
