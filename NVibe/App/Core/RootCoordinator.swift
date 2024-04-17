//
//  RootCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit

/// Root coordinator to use in AppDelegate, after delegating the navigation to the HomeCoordinator.
final class RootCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let coordinator = HomeCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}
