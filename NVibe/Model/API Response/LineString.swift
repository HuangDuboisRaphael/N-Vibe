//
//  LineString.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 20/04/2024.
//

import Foundation

struct LineString: Codable {
    let type: String
    var coordinates: [[Double]]
}
