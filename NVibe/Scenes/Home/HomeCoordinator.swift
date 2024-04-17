//
//  HomeCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit

final class HomeCoordinator: ParentCoordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private lazy var homeViewController: HomeViewController = {
        let viewController = HomeViewController()
        viewController.homeCoordinator = self
        return viewController
    }()
    
    func start() {
        add(self)
        pushViewController(homeViewController, animated: true)
    }
}
