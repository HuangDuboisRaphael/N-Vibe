//
//  MapboxNavigationCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 20/04/2024.
//

import Foundation
import MapboxNavigation
import MapboxDirections

protocol MapboxNavigationCoordinatorFlowDelegate: AnyObject {
    
}

final class MapboxNavigationCoordinator: BaseCoordinator {
    var childCoordinators = [Coordinator]()
    var finishFlow: (() -> Void)?
    
    private var parentViewController: HomeViewController
    
    init(parentViewController: HomeViewController) {
        self.parentViewController = parentViewController
    }
    
    private lazy var mapboxNavigationViewController: NavigationViewController = {
        let viewController = NavigationViewController(for: parentViewController.viewModel.routeResponse!, routeIndex: 0, routeOptions: parentViewController.viewModel.routeOptions)
        return viewController
    }()
        
    func start() {
        mapboxNavigationViewController.modalPresentationStyle = .fullScreen
        parentViewController.present(mapboxNavigationViewController, animated: true, completion: nil)
    }
}
