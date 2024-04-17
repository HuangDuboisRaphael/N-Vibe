//
//  ParentCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

/// All top-level coordinators need to conform to that protocol.
protocol ParentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get set }

    func add(_ child: Coordinator)
    func childDidFinish(_ child: Coordinator?)
}

extension ParentCoordinator {
    /// Add child coordinator to array.
    func add(_ child: Coordinator) {
        if childCoordinators.contains(where: { element in
            child === element
        }) {
            return
        }
        childCoordinators.append(child)
    }
    
    /// Remove child coordinator.
    func childDidFinish(_ child: Coordinator?) {
        guard let child = child else { return }
        childCoordinators = childCoordinators.filter { $0 !== child }
    }
}
