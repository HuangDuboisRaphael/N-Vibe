//
//  SearchLocationCoordinator.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 18/04/2024.
//

import UIKit

protocol SearchLocationCoordinatorFlowDelegate: AnyObject {
    func closeView()
}

final class SearchLocationCoordinator: BaseCoordinator {
    private var navigationController: UINavigationController
    private var parentViewController: UIViewController
    
    init(navigationController: UINavigationController, parentViewController: UIViewController) {
        self.navigationController = navigationController
        self.parentViewController = parentViewController
    }
    
    private lazy var searchLocationViewController: SearchLocationViewController = {
        let viewModel: SearchLocationViewModelRepresentable = SearchLocationViewModel(flowDelegate: self)
        let viewController = SearchLocationViewController(viewModel: viewModel)
        return viewController
    }()
        
    override func start() {
        navigationController.pushViewController(searchLocationViewController, animated: true)
    }
}

extension SearchLocationCoordinator: SearchLocationCoordinatorFlowDelegate {
    func closeView() {
        navigationController.popViewController(animated: true)
        finishFlow?()
    }
}
