//
//  ChildCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Foundation

/// All child coordinators should conform to this protocol
protocol ChildCoordinator: Coordinator {
    /// The body of this function should call `childDidFinish(_ child:)` on the parent coordinator to remove the child from parent's `childCoordinators`
    func coordinatorDidFinish()
}
