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
    var childCoordinators = [Coordinator]()
    var finishFlow: (() -> Void)?
    
    private var parentViewController: HomeViewController
    
    init(navigationController: UINavigationController, parentViewController: HomeViewController) {
        self.parentViewController = parentViewController
    }
    
    private lazy var searchLocationViewController: SearchLocationViewController = {
        let viewModel: SearchLocationViewModelRepresentable = SearchLocationViewModel(flowDelegate: self)
        let viewController = SearchLocationViewController(viewModel: viewModel)
        return viewController
    }()
        
    func start() {
        parentViewController.modalPresentationStyle = .fullScreen
        parentViewController.present(searchLocationViewController, animated: true)
    }
}

extension SearchLocationCoordinator: SearchLocationCoordinatorFlowDelegate {
    func closeView() {
        parentViewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentViewController.viewModel.selectedDestination = searchLocationViewController.viewModel.destination
            self.parentViewController.viewModel.didSelectDestination?()
            finishFlow?()
        }
    }
}
