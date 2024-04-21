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
    private var isSearchingArrival: Bool
    
    init(parentViewController: HomeViewController, isSearchingArrival: Bool) {
        self.parentViewController = parentViewController
        self.isSearchingArrival = isSearchingArrival
    }
    
    private lazy var searchLocationViewController: SearchLocationViewController = {
        let viewModel: SearchLocationViewModelRepresentable = SearchLocationViewModel(flowDelegate: self)
        let viewController = SearchLocationViewController(viewModel: viewModel, isSearchingArrival: isSearchingArrival)
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
            if searchLocationViewController.isSearchingArrival {
                if parentViewController.viewModel.selectedPlacemarkArrival == nil {
                    self.parentViewController.viewModel.selectedPlacemarkArrival = searchLocationViewController.viewModel.selectedPlacemarkArrival
                    self.parentViewController.viewModel.didSelectFirstArrival?()
                } else {
                    self.parentViewController.viewModel.selectedPlacemarkArrival = searchLocationViewController.viewModel.selectedPlacemarkArrival
                    self.parentViewController.viewModel.didSelectNewArrival?()
                }
            } else {
                self.parentViewController.viewModel.selectedPlacemarkStart = searchLocationViewController.viewModel.selectedPlacemarkStart
                self.parentViewController.viewModel.didSelectNewStart?()
            }
            finishFlow?()
        }
    }
}
