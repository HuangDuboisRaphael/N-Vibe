//
//  HomeCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit
import MapboxNavigation
import MapboxDirections

protocol HomeCoordinatorFlowDelegate: AnyObject {
    var navigationViewController: NavigationViewController? { get set }
    func displaySearchLocationView(forArrival: Bool)
    func displayMapboxNavigation()
}

final class HomeCoordinator: BaseCoordinator, HomeCoordinatorFlowDelegate {
    var childCoordinators = [Coordinator]()
    var finishFlow: (() -> Void)?
    var navigationViewController: NavigationViewController?
    
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
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.pushViewController(homeViewController, animated: true)
    }
    
    func displaySearchLocationView(forArrival isSearchingArrival: Bool) {
        let coordinator = SearchLocationCoordinator(parentViewController: homeViewController, isSearchingArrival: isSearchingArrival)
        coordinator.finishFlow = { [self, unowned coordinator] in
            remove(coordinator: coordinator)
        }
        add(coordinator: coordinator)
        coordinator.start()
    }
    
    func displayMapboxNavigation() {
        guard let routeResponse = homeViewController.viewModel.routeResponse else { return }
        navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: homeViewController.viewModel.routeOptions)
        guard let navigationViewController = navigationViewController else { return }
        navigationViewController.modalPresentationStyle = .fullScreen
        homeViewController.present(navigationViewController, animated: true)
    }
}
