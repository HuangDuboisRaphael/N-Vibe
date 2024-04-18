//
//  HomeViewController.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit
import MapboxNavigation

final class HomeViewController: UIViewController {    
    private let viewModel: HomeViewModelRepresentable
    
    private lazy var navigationMapView: NavigationMapView = {
        let view = NavigationMapView(frame: view.bounds)
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.addTarget(self, action: .searchButtonDidTapAction, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set magnifying glass icon
        let magnifyingGlassIcon = UIImage(systemName: "magnifyingglass")
        view.setImage(magnifyingGlassIcon, for: .normal)
        view.tintColor = .black
        
        // Set text on the right
        view.setTitle("Votre recherche", for: .normal)
        view.setTitleColor(.black.withAlphaComponent(0.5), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Set image and text position
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        view.contentHorizontalAlignment = .left
        
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = .prominent
//        view.searchTextField.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
 
    init(viewModel: HomeViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// UIViewController life cycle methods.
extension HomeViewController {
    override func loadView() {
        super.loadView()
        addLayouts()
        makeConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension HomeViewController {
    func addLayouts() {
        view.addSubview(navigationMapView)
        view.addSubview(searchButton)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

@objc
private extension HomeViewController {
    func searchButtonDidTap() {
        viewModel.displaySearchLocationView()
    }
}

private extension Selector {
    static let searchButtonDidTapAction = #selector(HomeViewController.searchButtonDidTap)
}
