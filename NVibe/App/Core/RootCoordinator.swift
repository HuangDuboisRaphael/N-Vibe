//
//  RootCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit

/// Root coordinator to use in AppDelegate, after delegating the navigation to the HomeCoordinator.
final class RootCoordinator: BaseCoordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() {
        let coordinator = HomeCoordinator(window: window)
        add(coordinator: coordinator)
        coordinator.start()
    }
}
