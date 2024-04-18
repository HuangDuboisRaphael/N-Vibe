//
//  Coordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit

/// App parent coordinator protocol.
protocol Coordinator: AnyObject {
    /// UINavigationController to be passed along the coordinators' hierarchy.
    func start()
}
