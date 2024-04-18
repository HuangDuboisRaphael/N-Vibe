//
//  HomeCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit

protocol HomeCoordinatorFlowDelegate: AnyObject {
    func displaySearchLocationView()
}

final class HomeCoordinator: BaseCoordinator {
    private let window: UIWindow
    private let navigationController = UINavigationController()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    private lazy var homeViewController: HomeViewController = {
        let viewModel: HomeViewModelRepresentable = HomeViewModel(flowDelegate: self)
        let viewController = HomeViewController(viewModel: viewModel)
        return viewController
    }()
    
    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.pushViewController(homeViewController, animated: true)
    }
}

extension HomeCoordinator: HomeCoordinatorFlowDelegate {
    func displaySearchLocationView() {
        let coordinator = SearchLocationCoordinator(navigationController: navigationController, parentViewController: homeViewController)
        coordinator.finishFlow = { [unowned self, unowned coordinator] in
            remove(coordinator: coordinator)
        }
        add(coordinator: coordinator)
        coordinator.start()
    }
}
