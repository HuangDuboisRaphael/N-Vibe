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
    private var pointAnnotationManager: PointAnnotationManager {
        navigationMapView.mapView.annotations.makePointAnnotationManager(id: Constants.AnnotationManager.pointIdentifer)
    }
    private var polylineAnnotationManager: PolylineAnnotationManager {
        navigationMapView.mapView.annotations.makePolylineAnnotationManager(id: Constants.AnnotationManager.polylineIdentifier)
    }
    
    private lazy var navigationMapView: NavigationMapView = {
        let view = NavigationMapView(frame: view.bounds)
        view.mapView.ornaments.options.compass.position = .bottomTrailing
        view.mapView.ornaments.logoView.isHidden = true
        view.mapView.ornaments.attributionButton.isHidden = true
        return view
    }()
    
    private lazy var searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchButton: UIButton = {
        let view = UIButton()
        view.layer.zPosition = 0
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
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        view.contentHorizontalAlignment = .left
        
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.layer.zPosition = 1
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: .cancelButtonDidTapAction, for: .touchUpInside)
        
        let image = UIImage(systemName: "xmark")
        view.setImage(image, for: .normal)
        view.tintColor = .black.withAlphaComponent(0.6)
        return view
    }()
    
    private lazy var currentUserLocationButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.6).cgColor
        view.addTarget(self, action: .currentUserLocationButtonDidTapAction, for: .touchUpInside)
        let image = UIImage(systemName: "paperplane.circle.fill")
        view.setImage(image, for: .normal)
        return view
    }()
    
    private lazy var directionButton: DirectionButton = {
        let view = DirectionButton(style: .itinerary)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: .itineraryButtonDidTapAction, for: .touchUpInside)
        return view
    }()
    
    private lazy var indicationLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFont(ofSize: 12)
        view.sizeToFit()
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
        return view
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = UIColor.black
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
        setupBindings()
    }
}

extension HomeViewController {
    func addLayouts() {
        searchContainerView.addSubview(searchButton)
        searchContainerView.addSubview(cancelButton)
        view.addSubview(navigationMapView)
        view.addSubview(searchContainerView)
        view.addSubview(currentUserLocationButton)
        view.addSubview(directionButton)
        view.addSubview(indicationLabel)
        view.addSubview(activityIndicatorView)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchButton.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            searchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            searchButton.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            currentUserLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            currentUserLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            currentUserLocationButton.widthAnchor.constraint(equalToConstant: 40),
            currentUserLocationButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            directionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            directionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            directionButton.widthAnchor.constraint(equalToConstant: 112),
            directionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            indicationLabel.topAnchor.constraint(equalTo: directionButton.bottomAnchor, constant: 4),
            indicationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupBindings() {
        viewModel.didSelectDestination = { [unowned self] in
            self.searchButton.setTitle(viewModel.selectedDestination?.name, for: .normal)
            self.searchButton.setTitleColor(.black, for: .normal)
            self.cancelButton.isHidden = false
            self.addAnnotation(at: self.viewModel.destination.coordinate)
            self.centerCameraToDestination()
        }
        
        viewModel.didCalculateRoute = { [unowned self] in
            self.drawRoute()
            self.centerCameraToCalculatedRoute()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.directionButton.changeStyle(.start)
            self.directionButton.isHidden = false
            self.indicationLabel.isHidden = false
            self.indicationLabel.text = self.viewModel.indicationLabelText
        }
    }
}

/// All methods related to routes, camera and annotation.
private extension HomeViewController {
    func centerCameraToUserCurrentLocation() {
        let animator = navigationMapView.mapView.camera.makeAnimator(duration: 0.8, curve: .easeIn) { transition in
            transition.zoom.toValue = 16
            transition.center.toValue = LocationManager.shared.currentLocation.coordinate
        }
        animator.startAnimation()
    }
    
    func drawRoute() {
        var annotation = PolylineAnnotation(lineCoordinates: viewModel.lineCoordinates)
        annotation.lineColor = StyleColor(.red)
        annotation.lineWidth = 8
        annotation.lineOpacity = 0.5

        polylineAnnotationManager.annotations = [annotation]
    }
    
    func centerCameraToDestination() {
        let animator = navigationMapView.mapView.camera.makeAnimator(duration: 0.8, curve: .easeIn) { [unowned self] transition in
            transition.zoom.toValue = 15
            transition.center.toValue = self.viewModel.destination.coordinate
        }
        animator.startAnimation()
        animator.addCompletion { [unowned self] _ in
            self.directionButton.isHidden = false
        }
    }
    
    func addAnnotation(at coordinate: CLLocationCoordinate2D) {
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        pointAnnotation.image = .init(image: UIImage(named: "dest-pin")!, name: "dest-pin")
        pointAnnotationManager.annotations = [pointAnnotation]
    }
    
    func centerCameraToCalculatedRoute() {
        let bounds = CoordinateBounds(
            southwest: viewModel.origin.coordinate,
            northeast: viewModel.destination.coordinate)
        let camera = navigationMapView.mapView.mapboxMap.camera(
            for: bounds,
            padding: UIEdgeInsets(top: view.safeAreaInsets.top + searchContainerView.frame.height + 24, left: 80, bottom: view.safeAreaInsets.bottom + directionButton.frame.height + 24, right: 80),
            bearing: 0,
            pitch: 0
        )
        navigationMapView.mapView.camera.ease(to: camera, duration: 0.5)
    }
}

@objc
private extension HomeViewController {
    func searchButtonDidTap() {
        viewModel.displaySearchLocationView()
    }
    
    func cancelButtonDidTap() {
        navigationMapView.removeRouteDurations()
        navigationMapView.removeRoutes()
        navigationMapView.removeWaypoints()
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
        searchButton.setTitle("Votre recherche", for: .normal)
        searchButton.setTitleColor(.black.withAlphaComponent(0.5), for: .normal)
        cancelButton.isHidden = true
        directionButton.isHidden = true
        directionButton.changeStyle(.itinerary)
        indicationLabel.isHidden = true
    }
    
    func currentUserLocationButtonDidTap() {
        centerCameraToUserCurrentLocation()
    }
    
    func itineraryButtonDidTap(sender: DirectionButton) {
        if sender.style == .itinerary {
            directionButton.isHidden = true
            activityIndicatorView.startAnimating()
            activityIndicatorView.isHidden = false
            viewModel.calculateRouteWithApi()
        } else {
            viewModel.displayMapboxNavigation()
        }
    }
}

private extension Selector {
    static let searchButtonDidTapAction = #selector(HomeViewController.searchButtonDidTap)
    static let cancelButtonDidTapAction = #selector(HomeViewController.cancelButtonDidTap)
    static let currentUserLocationButtonDidTapAction = #selector(HomeViewController.currentUserLocationButtonDidTap)
    static let itineraryButtonDidTapAction = #selector(HomeViewController.itineraryButtonDidTap)
}
