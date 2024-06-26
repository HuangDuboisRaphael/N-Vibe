//
//  BaseCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

/// Protocol to be used by all coordinators other than root including child coordinators stack management and finishFlow closure.
protocol BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var finishFlow: (() -> Void)? { get set }
    
    func add(coordinator: Coordinator)
    func remove(coordinator: Coordinator?)
}

extension BaseCoordinator {
    func add(coordinator: Coordinator) {
        if childCoordinators.contains(where: { element in
            coordinator === element
        }) {
            return
        }
        childCoordinators.append(coordinator)
    }
    
    func remove(coordinator: Coordinator?) {
        guard let coordinator = coordinator else { return }
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
