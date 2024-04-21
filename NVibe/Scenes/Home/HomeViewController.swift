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
    
    private lazy var locationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var originSearchButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 4
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.addTarget(self, action: .originSearchButtonDidTapAction, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set text on the right
        view.setTitle("Votre position", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Set image and text position
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.contentHorizontalAlignment = .left
        
        return view
    }()
    
    private lazy var destinationSearchButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 4
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.addTarget(self, action: .destinationSearchButtonDidTapAction, for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set text on the right
        view.setTitleColor(.black, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        // Set image and text position
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.contentHorizontalAlignment = .left
        
        return view
    }()
    
    private lazy var cancelStartNavigationButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: .cancelStartNavigationButtonDidTapAction, for: .touchUpInside)
        let image = UIImage(systemName: "chevron.left")?.resizeImage(targetSize: CGSize(width: 20, height: 20))
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        return view
    }()
    
    private lazy var swapLocationButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: .swapLocationButtonDidTapAction, for: .touchUpInside)
        let image = UIImage(systemName: "arrow.up.arrow.down")
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

extension HomeViewController {
    func addLayouts() {
        searchContainerView.addSubview(searchButton)
        searchContainerView.addSubview(cancelButton)
        locationContainerView.addSubview(originSearchButton)
        locationContainerView.addSubview(destinationSearchButton)
        locationContainerView.addSubview(cancelStartNavigationButton)
        locationContainerView.addSubview(swapLocationButton)
        view.addSubview(navigationMapView)
        view.addSubview(searchContainerView)
        view.addSubview(locationContainerView)
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
            locationContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            locationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationContainerView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.23)
        ])
        
        NSLayoutConstraint.activate([
            destinationSearchButton.centerXAnchor.constraint(equalTo: locationContainerView.centerXAnchor),
            destinationSearchButton.bottomAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: -12),
            destinationSearchButton.heightAnchor.constraint(equalToConstant: 40),
            destinationSearchButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
        ])
        
        NSLayoutConstraint.activate([
            originSearchButton.centerXAnchor.constraint(equalTo: locationContainerView.centerXAnchor),
            originSearchButton.bottomAnchor.constraint(equalTo: destinationSearchButton.topAnchor, constant: -12),
            originSearchButton.heightAnchor.constraint(equalToConstant: 40),
            originSearchButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
        ])
        
        NSLayoutConstraint.activate([
            cancelStartNavigationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelStartNavigationButton.centerYAnchor.constraint(equalTo: originSearchButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            swapLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            swapLocationButton.centerYAnchor.constraint(equalTo: destinationSearchButton.centerYAnchor)
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
}

private extension HomeViewController {
    func setupBindings() {
        viewModel.isLoadingBackgroundTasks = { [unowned self] in
            self.directionButton.isHidden = true
            self.indicationLabel.isHidden = true
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
        }
        
        viewModel.didSelectFirstDestination = { [unowned self] in
            self.searchButton.setTitle(viewModel.selectedDestination?.name, for: .normal)
            self.searchButton.setTitleColor(.black, for: .normal)
            self.cancelButton.isHidden = false
            self.addAnnotation(at: self.viewModel.selectedDestination?.coordinate ?? CLLocationCoordinate2D())
            self.centerCameraToDestination()
        }
        
        viewModel.didSelectNewOrigin = { [unowned self] in
            self.originSearchButton.setTitle(viewModel.selectedOrigin?.name, for: .normal)
            self.navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
            self.viewModel.calculateRouteWithApi()
        }
        
        viewModel.didSelectNewDestination = { [unowned self] in
            self.destinationSearchButton.setTitle(viewModel.selectedDestination?.name, for: .normal)
            self.navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
            self.viewModel.calculateRouteWithApi()
        }
        
        viewModel.didCalculateRoute = { [unowned self] in
            self.addAnnotations()
            self.drawRoute()
            self.centerCameraToCalculatedRoute()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.searchContainerView.isHidden = true
            self.directionButton.changeStyle(.start)
            self.directionButton.isHidden = false
            self.indicationLabel.isHidden = false
            self.indicationLabel.text = self.viewModel.indicationLabelText
            self.locationContainerView.isHidden = false
            self.destinationSearchButton.setTitle(viewModel.selectedDestination?.name, for: .normal)
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
            transition.center.toValue = self.viewModel.selectedDestination?.coordinate ?? CLLocationCoordinate2D()
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
    
    func addAnnotations() {
        self.navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        var originAnnotation: PointAnnotation?
        if viewModel.selectedOrigin != nil {
            originAnnotation = PointAnnotation(coordinate: viewModel.selectedOrigin!.coordinate)
            originAnnotation?.image = .init(image: UIImage(named: "orig-pin")!, name: "orig-pin")
        }
        var destinationAnnotation = PointAnnotation(coordinate: viewModel.selectedDestination?.coordinate ?? CLLocationCoordinate2D())
        destinationAnnotation.image = .init(image: UIImage(named: "dest-pin")!, name: "dest-pin")
        if originAnnotation != nil {
            pointAnnotationManager.annotations = [originAnnotation!, destinationAnnotation]
        } else {
            pointAnnotationManager.annotations = [destinationAnnotation]
        }
    }
    
    func swapAnnotations() {
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        if originSearchButton.title(for: .normal) == "Votre position" {
            var pointAnnotation = PointAnnotation(coordinate: viewModel.selectedDestination?.coordinate ?? CLLocationCoordinate2D())
            pointAnnotation.image = .init(image: UIImage(named: "dest-pin")!, name: "dest-pin")
            pointAnnotationManager.annotations = [pointAnnotation]
        } else if destinationSearchButton.title(for: .normal) == "Votre position" {
            var pointAnnotation = PointAnnotation(coordinate: viewModel.selectedOrigin?.coordinate ?? CLLocationCoordinate2D())
            pointAnnotation.image = .init(image: UIImage(named: "orig-pin")!, name: "orig-pin")
            pointAnnotationManager.annotations = [pointAnnotation]
        } else {
            var originAnnotation = PointAnnotation(coordinate: viewModel.selectedOrigin?.coordinate ?? CLLocationCoordinate2D())
            originAnnotation.image = .init(image: UIImage(named: "orig-pin")!, name: "orig-pin")
            var destinationAnnotation = PointAnnotation(coordinate: viewModel.selectedDestination?.coordinate ?? CLLocationCoordinate2D())
            destinationAnnotation.image = .init(image: UIImage(named: "dest-pin")!, name: "dest-pin")
            pointAnnotationManager.annotations = [originAnnotation, destinationAnnotation]
        }
    }
    
    func centerCameraToCalculatedRoute() {
        let bounds = CoordinateBounds(
            southwest: viewModel.selectedOrigin == nil ? LocationManager.shared.currentLocation.coordinate : viewModel.selectedOrigin!.coordinate,
            northeast: viewModel.selectedDestination?.coordinate ?? CLLocationCoordinate2D())
        let camera = navigationMapView.mapView.mapboxMap.camera(
            for: bounds,
            padding: UIEdgeInsets(top: locationContainerView.bounds.height + 32, left: 80, bottom: view.safeAreaInsets.bottom + directionButton.frame.height + 24, right: 80),
            bearing: 0,
            pitch: 0
        )
        navigationMapView.mapView.camera.ease(to: camera, duration: 0.5)
    }
}

@objc
private extension HomeViewController {
    func searchButtonDidTap() {
        viewModel.displaySearchLocationView(forDestination: true)
    }
    
    func cancelButtonDidTap() {
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
        searchButton.setTitle("Votre recherche", for: .normal)
        searchButton.setTitleColor(.black.withAlphaComponent(0.5), for: .normal)
        cancelButton.isHidden = true
        directionButton.isHidden = true
        directionButton.changeStyle(.itinerary)
        indicationLabel.isHidden = true
        viewModel.selectedOrigin = nil
        viewModel.selectedDestination = nil
    }
    
    func originSearchButtonDidTap() {
        viewModel.displaySearchLocationView(forDestination: false)
    }
    
    func destinationSearchButtonDidTap() {
        viewModel.displaySearchLocationView(forDestination: true)
    }
    
    func cancelStartNavigationButtonDidTap() {
        searchContainerView.isHidden = false
        locationContainerView.isHidden = true
        searchButton.setTitle("Votre recherche", for: .normal)
        originSearchButton.setTitle("Votre position", for: .normal)
        searchButton.setTitleColor(.black.withAlphaComponent(0.5), for: .normal)
        cancelButton.isHidden = true
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
        directionButton.isHidden = true
        directionButton.changeStyle(.itinerary)
        indicationLabel.isHidden = true
        viewModel.selectedOrigin = nil
        viewModel.selectedDestination = nil
    }
    
    func swapLocationButtonDidTap() {
        if originSearchButton.title(for: .normal) == "Votre position" {
            viewModel.selectedOrigin = viewModel.selectedDestination ?? (name: "", coordinate: CLLocationCoordinate2D())
            viewModel.selectedDestination?.coordinate = LocationManager.shared.currentLocation.coordinate
            viewModel.selectedDestination?.name = "Votre position"
            originSearchButton.setTitle(viewModel.selectedOrigin?.name, for: .normal)
            destinationSearchButton.setTitle(viewModel.selectedDestination?.name, for: .normal)
        } else if destinationSearchButton.title(for: .normal) == "Votre position" {
            viewModel.selectedDestination = viewModel.selectedOrigin ?? (name: "", coordinate: CLLocationCoordinate2D())
            viewModel.selectedOrigin?.coordinate = LocationManager.shared.currentLocation.coordinate
            viewModel.selectedOrigin?.name = "Votre position"
            destinationSearchButton.setTitle(viewModel.selectedDestination?.name, for: .normal)
            originSearchButton.setTitle(viewModel.selectedOrigin?.name, for: .normal)
        } else {
            let selectedOrigin = viewModel.selectedOrigin ?? (name: "", coordinate: CLLocationCoordinate2D())
            viewModel.selectedOrigin = viewModel.selectedDestination
            originSearchButton.setTitle(viewModel.selectedOrigin?.name, for: .normal)
            viewModel.selectedDestination = selectedOrigin
            destinationSearchButton.setTitle(selectedOrigin.name, for: .normal)
        }
        swapAnnotations()
    }
    
    func currentUserLocationButtonDidTap() {
        centerCameraToUserCurrentLocation()
    }
    
    func itineraryButtonDidTap(sender: DirectionButton) {
        if sender.style == .itinerary {
            directionButton.isHidden = true
            viewModel.calculateRouteWithApi()
        } else {
            viewModel.tryDisplayingMapboxNavigation()
        }
    }
}

private extension Selector {
    static let searchButtonDidTapAction = #selector(HomeViewController.searchButtonDidTap)
    static let cancelButtonDidTapAction = #selector(HomeViewController.cancelButtonDidTap)
    static let originSearchButtonDidTapAction = #selector(HomeViewController.originSearchButtonDidTap)
    static let destinationSearchButtonDidTapAction = #selector(HomeViewController.destinationSearchButtonDidTap)
    static let cancelStartNavigationButtonDidTapAction = #selector(HomeViewController.cancelStartNavigationButtonDidTap)
    static let swapLocationButtonDidTapAction = #selector(HomeViewController.swapLocationButtonDidTap)
    static let currentUserLocationButtonDidTapAction = #selector(HomeViewController.currentUserLocationButtonDidTap)
    static let itineraryButtonDidTapAction = #selector(HomeViewController.itineraryButtonDidTap)
}
