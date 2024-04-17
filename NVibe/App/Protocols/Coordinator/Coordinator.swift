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
    var navigationController: UINavigationController { get set }
    
    func start()
}

/// List all navigation methods that would be implicitly available for every object conforming to the Coordinator protocol, can also apply custom navigation methods.
extension Coordinator {
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
}
