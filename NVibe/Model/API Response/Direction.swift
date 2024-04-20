//
//  Direction.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

struct Direction: Codable {
    let code: String
    let routes: [RouteResponseAPI]
}
