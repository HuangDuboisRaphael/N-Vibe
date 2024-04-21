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
    private var isSearchingADestination: Bool
    
    init(parentViewController: HomeViewController, isSearchingADestination: Bool) {
        self.parentViewController = parentViewController
        self.isSearchingADestination = isSearchingADestination
    }
    
    private lazy var searchLocationViewController: SearchLocationViewController = {
        let viewModel: SearchLocationViewModelRepresentable = SearchLocationViewModel(flowDelegate: self)
        let viewController = SearchLocationViewController(viewModel: viewModel, isSearchingADestination: isSearchingADestination)
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
            if searchLocationViewController.isSearchingADestination {
                if parentViewController.viewModel.selectedDestination == nil {
                    self.parentViewController.viewModel.selectedDestination = searchLocationViewController.viewModel.selectedDestination
                    self.parentViewController.viewModel.didSelectFirstDestination?()
                } else {
                    self.parentViewController.viewModel.selectedDestination = searchLocationViewController.viewModel.selectedDestination
                    self.parentViewController.viewModel.didSelectNewDestination?()
                }
            } else {
                self.parentViewController.viewModel.selectedOrigin = searchLocationViewController.viewModel.selectedOrigin
                self.parentViewController.viewModel.didSelectNewOrigin?()
            }
            finishFlow?()
        }
    }
}
