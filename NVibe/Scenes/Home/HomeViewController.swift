//
//  HomeViewController.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit
import MapboxNavigation
import MapboxMaps

final class HomeViewController: UIViewController {
    let viewModel: HomeViewModelRepresentable
    var beginAnnotation: PointAnnotation?
    
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
        setupBindings()
        navigationMapView.mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.navigationMapView.pointAnnotationManager?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomeViewController: AnnotationInteractionDelegate {
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
    
    func setupBindings() {
        viewModel.didCalculateRoute = { [unowned self] in
            self.drawRoute()
            
            if var annotation = navigationMapView.pointAnnotationManager?.annotations.first {
                // Display callout view on destination annotation
                annotation.textField = "Start navigation"
                annotation.textColor = .init(UIColor.white)
                annotation.textHaloColor = .init(UIColor.systemBlue)
                annotation.textHaloWidth = 2
                annotation.textAnchor = .top
                annotation.textRadialOffset = 1.0
                
                beginAnnotation = annotation
                navigationMapView.pointAnnotationManager?.annotations = [annotation]
            }
  
        }
    }
    
    func drawRoute() {
        guard let route = viewModel.route else { return }
        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])
        
        // Show destination waypoint on the map
        navigationMapView.showWaypoints(on: route)
    }

    // Present the navigation view controller when the annotation is selected
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard annotations.first?.id == beginAnnotation?.id,
              let routeResponse = viewModel.routeResponse else {
            return
        }
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: viewModel.routeOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
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
