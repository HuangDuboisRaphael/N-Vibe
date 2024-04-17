//
//  Waypoint.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

struct Waypoint: Codable {
    let name: String
    let location: [Double]
    let distance: Double?
}
