//
//  RootCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit

/// Root coordinator to use in AppDelegate, after delegating the navigation to the HomeCoordinator.
final class RootCoordinator: Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let coordinator = HomeCoordinator(window: window)
        coordinator.start()
    }
}
