//
//  BaseCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

class BaseCoordinator: NSObject, Coordinator, CoordinatorFinishOutput {
    var finishFlow: (() -> Void)?
    var childCoordinators = [Coordinator]()

    func start() {
        fatalError("Children should implement `start`.")
    }
    
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
