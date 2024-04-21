//
//  Double+Extensions.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 20/04/2024.
//

import Foundation

extension Double {
    func convertDurationToText() -> String {
        let minutes = Int(self / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h\(remainingMinutes)"
        } else {
            return "\(minutes)min"
        }
    }
    
    func convertDistanceToText() -> String {
        if self < 1000 {
            return "\(Int(self)) meters"
        } else {
            let distanceInKilometers = self / 1000.0
            return "\(String(format: "%.1f", distanceInKilometers)) km"
        }
    }
}
