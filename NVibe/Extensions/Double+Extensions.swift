//
//  Double+Extensions.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 20/04/2024.
//

import Foundation

extension Double {
    func convertDurationToText() -> String {
        // Convert seconds to minutes and round to the nearest minute
        let durationInMinutes = Int((self / 60).rounded())

        // Create a string representing the duration in minutes
        let minutes = "\(durationInMinutes) min"
        
        return minutes
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
