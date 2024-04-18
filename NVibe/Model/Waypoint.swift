//
//  Waypoint.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

struct WaypointResponse: Codable {
    let name: String
    let location: [Double]
    let distance: Double?
}
