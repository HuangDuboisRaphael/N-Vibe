//
//  HomeViewController.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit
import Combine
import MapboxNavigation
import MapboxMaps
import MapboxDirections

final class HomeViewController: UIViewController {
    // MARK: - Properties
    /// ViewModel interface injected with dependency injection.
    let viewModel: HomeViewModelRepresentable
    
    private enum SearchLocationState {
        case emptyStart
        case emptyArrival
        case bothFilled
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private var searchLocationState: SearchLocationState {
        startSearchButton.title(for: .normal) == "Votre position" ? .emptyStart :
        arrivalSearchButton.title(for: .normal) == "Votre position" ? .emptyArrival : .bothFilled
    }
    
    /// Managers to add and remove annotations.
    private var pointAnnotationManager: PointAnnotationManager {
        navigationMapView.mapView.annotations.makePointAnnotationManager(id: Constants.AnnotationManager.pointIdentifer)
    }
    private var polylineAnnotationManager: PolylineAnnotationManager {
        navigationMapView.mapView.annotations.makePolylineAnnotationManager(id: Constants.AnnotationManager.polylineIdentifier)
    }
    
    /// All UIView components.
    private lazy var navigationMapView: NavigationMapView = {
        let view = NavigationMapView(frame: view.bounds)
        view.mapView.ornaments.options.compass.position = .bottomTrailing
        view.mapView.ornaments.logoView.isHidden = true
        view.mapView.ornaments.attributionButton.isHidden = true
        view.mapView.mapboxMap.setCamera(to: CameraOptions(center: LocationManager.shared.currentLocation.coordinate, zoom: 16))
        return view
    }()
    
    private lazy var mainSearchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mainSearchButton: UIButton = {
        let view = UIButton()
        view.setGeneralComponents(self, action: .searchButtonDidTapAction, backgroundColor: .white)
        view.layer.zPosition = 0
        view.layer.cornerRadius = 20
        view.setSystemImage(named: "magnifyingglass", color: .black)
        view.setTitle("Votre recherche", color: .black.withAlphaComponent(0.5), font: UIFont.systemFont(ofSize: 16))
        view.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        view.contentHorizontalAlignment = .left
        view.isHidden = true
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.setGeneralComponents(self, action: .cancelButtonDidTapAction)
        view.setSystemImage(named: "xmark", color: .black.withAlphaComponent(0.6))
        view.layer.zPosition = 1
        view.isHidden = true
        return view
    }()
    
    private lazy var locationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var startSearchButton: PlacemarkSearchButton = {
        let view = PlacemarkSearchButton(title: "Votre position", target: self, action: .startSearchButtonDidTapAction)
        return view
    }()
    
    private lazy var arrivalSearchButton: PlacemarkSearchButton = {
        let view = PlacemarkSearchButton(title: "", target: self, action: .arrivalSearchButtonDidTapAction)
        return view
    }()
    
    private lazy var cancelStartNavigationButton: UIButton = {
        let view = UIButton()
        view.setGeneralComponents(self, action: .cancelStartNavigationButtonDidTapAction)
        let image = UIImage(systemName: "chevron.left")?.resizeImage(targetSize: CGSize(width: 20, height: 20))
        view.tintColor = .black
        view.setImage(image, for: .normal)
        view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        return view
    }()
    
    private lazy var swapLocationButton: UIButton = {
        let view = UIButton()
        view.setGeneralComponents(self, action: .swapLocationButtonDidTapAction)
        view.setSystemImage(named: "arrow.up.arrow.down", color: .black)
        view.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
        return view
    }()
    
    private lazy var currentUserLocationButton: UIButton = {
        let view = UIButton()
        view.setGeneralComponents(self, action: .currentUserLocationButtonDidTapAction, backgroundColor: .white)
        view.layer.cornerRadius = 20
        view.setSystemImage(named: "paperplane.circle.fill")
        view.setBorder(width: 0.5, color: .black.withAlphaComponent(0.6))
        view.isHidden = true
        return view
    }()
    
    private lazy var directionButton: DirectionButton = {
        let view = DirectionButton(style: .itinerary)
        view.setGeneralComponents(self, action: .directionButtonDidTapAction, backgroundColor: .white)
        view.isHidden = true
        return view
    }()
    
    private lazy var indicationLabel: UILabel = {
        let view = UILabel()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.boldSystemFont(ofSize: 12)
        /// To fit container view width.
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
    
    private lazy var errorBannerView: ErrorBannerView = {
        let view = ErrorBannerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
 
    // MARK: - Initialization
    init(viewModel: HomeViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewController life cycle methods.
extension HomeViewController {
    override func loadView() {
        super.loadView()
        addLayouts()
        makeConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        subscribeToCoordinatePublisher()
        displayUserDeniedLocationAlert()
    }
}

// MARK: Add views and make autolayout constraints.
private extension HomeViewController {
    func addLayouts() {
        mainSearchContainerView.addSubview(mainSearchButton)
        mainSearchContainerView.addSubview(cancelButton)
        locationContainerView.addSubview(startSearchButton)
        locationContainerView.addSubview(arrivalSearchButton)
        locationContainerView.addSubview(cancelStartNavigationButton)
        locationContainerView.addSubview(swapLocationButton)
        view.addSubview(navigationMapView)
        view.addSubview(mainSearchContainerView)
        view.addSubview(locationContainerView)
        view.addSubview(currentUserLocationButton)
        view.addSubview(directionButton)
        view.addSubview(indicationLabel)
        view.addSubview(activityIndicatorView)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            mainSearchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainSearchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainSearchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainSearchContainerView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            mainSearchButton.topAnchor.constraint(equalTo: mainSearchContainerView.topAnchor),
            mainSearchButton.leadingAnchor.constraint(equalTo: mainSearchContainerView.leadingAnchor),
            mainSearchButton.trailingAnchor.constraint(equalTo: mainSearchContainerView.trailingAnchor),
            mainSearchButton.bottomAnchor.constraint(equalTo: mainSearchContainerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: mainSearchContainerView.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: mainSearchContainerView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            locationContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            locationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationContainerView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.23)
        ])
        
        NSLayoutConstraint.activate([
            arrivalSearchButton.centerXAnchor.constraint(equalTo: locationContainerView.centerXAnchor),
            arrivalSearchButton.bottomAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: -12),
            arrivalSearchButton.heightAnchor.constraint(equalToConstant: 40),
            arrivalSearchButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
        ])
        
        NSLayoutConstraint.activate([
            startSearchButton.centerXAnchor.constraint(equalTo: locationContainerView.centerXAnchor),
            startSearchButton.bottomAnchor.constraint(equalTo: arrivalSearchButton.topAnchor, constant: -12),
            startSearchButton.heightAnchor.constraint(equalToConstant: 40),
            startSearchButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
        ])
        
        NSLayoutConstraint.activate([
            cancelStartNavigationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelStartNavigationButton.centerYAnchor.constraint(equalTo: startSearchButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            swapLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            swapLocationButton.centerYAnchor.constraint(equalTo: arrivalSearchButton.centerYAnchor)
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
    
    func makeErrorBannerViewConstraints() {
        NSLayoutConstraint.activate([
            errorBannerView.topAnchor.constraint(equalTo: view.topAnchor),
            errorBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorBannerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

// MARK: ViewModel bindings.
private extension HomeViewController {
    func setupBindings() {
        viewModel.isLoadingBackgroundTasks = { [unowned self] in
            self.directionButton.isHidden = true
            self.indicationLabel.isHidden = true
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.isHidden = false
        }
        
        viewModel.didSelectFirstArrival = { [unowned self] in
            self.mainSearchButton.setTitle(viewModel.selectedPlacemarkArrival?.name ?? "", color: .black)
            self.cancelButton.isHidden = false
            self.addAnnotations()
            self.centerCameraToArrival()
        }
        
        viewModel.didSelectNewStart = { [unowned self] in
            self.startSearchButton.setTitle(viewModel.selectedPlacemarkStart?.name, for: .normal)
            self.didSelectLocationAction()
        }
        
        viewModel.didSelectNewArrival = { [unowned self] in
            self.arrivalSearchButton.setTitle(viewModel.selectedPlacemarkArrival?.name, for: .normal)
            self.didSelectLocationAction()
        }
        
        viewModel.didCalculateRoute = { [unowned self] in
            self.addAnnotations()
            self.drawRoute()
            self.centerCameraToCalculatedRoute()
            self.finishLoadingAction()
            self.mainSearchContainerView.isHidden = true
            self.indicationLabel.isHidden = false
            self.indicationLabel.text = self.viewModel.indicationLabelText
            self.locationContainerView.isHidden = false
            self.arrivalSearchButton.setTitle(viewModel.selectedPlacemarkArrival?.name, for: .normal)
            self.directionButton.changeStyle(self.searchLocationState == .emptyStart ? .start : .inProgress)
            self.directionButton.isEnabled = self.searchLocationState == .emptyStart ? true : false
        }
        
        viewModel.didFailLoading = { [unowned self] error in
            if let error = error as? APIErrorHandler {
                if error == .noConnection {
                    self.showErrorBannerView(error: Constants.MessageError.noInternetConnection)
                } else {
                    self.showErrorBannerView(error: Constants.MessageError.cannotRecoverData)
                }
            } else if let _ = error as? DirectionsError {
                self.showErrorBannerView(error: Constants.MessageError.cannotStartItinerary)
            } else {
                self.showErrorBannerView(error: Constants.MessageError.defaultMessageError)
            }
            self.finishLoadingAction()
            self.directionButton.style = .itinerary
        }
    }
}

// MARK: LocationManager bindings.
private extension HomeViewController {
    func displayUserDeniedLocationAlert() {
        LocationManager.shared.deniedLocationAccessPublisher
            .sink { [unowned self] in
                self.viewModel.displayUserLocationAlert(
                    title: Constants.MessageError.warning,
                    message: Constants.MessageError.locationDisabled)
            }
            .store(in: &cancellables)
    }
    
    func subscribeToCoordinatePublisher() {
        LocationManager.shared.coordinatePublisher
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.viewModel.displayUserLocationAlert(
                        title: Constants.MessageError.warning,
                        message: Constants.MessageError.cannotRecoverLocation)
                }
            } receiveValue: { [unowned self] in
                self.mainSearchButton.isHidden = false
                self.currentUserLocationButton.isHidden = false
                self.currentUserLocationButtonDidTap()
            }
            .store(in: &cancellables)
    }
}

// MARK: All methods related to camera, routes and annotations.
private extension HomeViewController {
    func centerCameraToUserCurrentLocation() {
        let animator = navigationMapView.mapView.camera.makeAnimator(duration: 0.8, curve: .easeIn) { transition in
            transition.zoom.toValue = 16
            transition.center.toValue = LocationManager.shared.currentLocation.coordinate
        }
        animator.startAnimation()
    }
    
    func centerCameraToArrival() {
        let animator = navigationMapView.mapView.camera.makeAnimator(duration: 0.8, curve: .easeIn) { [unowned self] transition in
            transition.zoom.toValue = 15
            transition.center.toValue = self.viewModel.selectedPlacemarkArrival?.coordinate ?? CLLocationCoordinate2D()
        }
        animator.startAnimation()
        animator.addCompletion { [unowned self] _ in
            self.directionButton.isHidden = false
        }
    }
    
    func centerCameraToCalculatedRoute() {
        let bounds = CoordinateBounds(
            southwest: viewModel.selectedPlacemarkStart == nil ? LocationManager.shared.currentLocation.coordinate : viewModel.selectedPlacemarkStart!.coordinate,
            northeast: viewModel.selectedPlacemarkArrival?.coordinate ?? CLLocationCoordinate2D())
        let camera = navigationMapView.mapView.mapboxMap.camera(
            for: bounds,
            padding: UIEdgeInsets(top: locationContainerView.bounds.height + 32, left: 80, bottom: view.safeAreaInsets.bottom + directionButton.frame.height + 24, right: 80),
            bearing: 0,
            pitch: 0
        )
        navigationMapView.mapView.camera.ease(to: camera, duration: 0.5)
    }
    
    func drawRoute() {
        var annotation = PolylineAnnotation(lineCoordinates: viewModel.lineCoordinates)
        annotation.lineColor = StyleColor(.red)
        annotation.lineWidth = 8
        annotation.lineOpacity = 0.5
        polylineAnnotationManager.annotations = [annotation]
    }
    
    func createAnnotation(_ name: String, at coordinate: CLLocationCoordinate2D, isVisible: Bool = false) -> PointAnnotation {
        var annotation = PointAnnotation(coordinate: coordinate)
        annotation.image = .init(image: UIImage(named: name)!, name: name)
        if isVisible {
            pointAnnotationManager.annotations = [annotation]
        }
        return annotation
    }
    
    func addAnnotations() {
        self.navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        var startAnnotation: PointAnnotation?
        if viewModel.selectedPlacemarkStart != nil {
            startAnnotation = createAnnotation(Constants.PointAnnotation.start, at: viewModel.selectedPlacemarkStart!.coordinate)
        }
        let arrivalAnnotation = createAnnotation(Constants.PointAnnotation.arrival, at: viewModel.selectedPlacemarkArrival?.coordinate ?? CLLocationCoordinate2D())
        if startAnnotation != nil {
            pointAnnotationManager.annotations = [startAnnotation!, arrivalAnnotation]
        } else {
            pointAnnotationManager.annotations = [arrivalAnnotation]
        }
    }
    
    func swapAnnotations() {
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        switch searchLocationState {
        case .emptyStart:
            _ = createAnnotation(Constants.PointAnnotation.start, at: viewModel.selectedPlacemarkArrival?.coordinate ?? CLLocationCoordinate2D(), isVisible: true)
        case .emptyArrival:
            _ = createAnnotation(Constants.PointAnnotation.arrival, at: viewModel.selectedPlacemarkStart?.coordinate ?? CLLocationCoordinate2D(), isVisible: true)
        case .bothFilled:
            let startAnnotation = createAnnotation(Constants.PointAnnotation.arrival, at: viewModel.selectedPlacemarkStart?.coordinate ?? CLLocationCoordinate2D())
            let arrivalAnnotation = createAnnotation(Constants.PointAnnotation.start, at: viewModel.selectedPlacemarkArrival?.coordinate ?? CLLocationCoordinate2D())
            pointAnnotationManager.annotations = [startAnnotation, arrivalAnnotation]
        }
    }
}

// MARK: Refactoring altering UIView state methods.
private extension HomeViewController {
    func finishLoadingAction() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        directionButton.isHidden = false
    }
    
    func didSelectLocationAction() {
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
        viewModel.calculateRouteWithApi()
    }
            
    func cancelAction() {
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.pointIdentifer)
        navigationMapView.mapView.annotations.removeAnnotationManager(withId: Constants.AnnotationManager.polylineIdentifier)
        mainSearchButton.setTitle("Votre recherche", color: .black.withAlphaComponent(0.5))
        cancelButton.isHidden = true
        directionButton.isHidden = true
        directionButton.isEnabled = true
        directionButton.changeStyle(.itinerary)
        indicationLabel.isHidden = true
        viewModel.selectedPlacemarkStart = nil
        viewModel.selectedPlacemarkArrival = nil
    }
}

// MARK: Method related to ErrorBannerView.
private extension HomeViewController {
    func showErrorBannerView(error: String) {
        errorBannerView.setError(error)
        view.addSubview(errorBannerView)
        makeErrorBannerViewConstraints()
        
        /// Animate showing the banner
        UIView.animate(withDuration: 0.5) {
            self.errorBannerView.frame.origin.y = 0
        }
        
        /// Dismiss the banner after a certain duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.5) {
                self.errorBannerView.frame.origin.y = -self.errorBannerView.frame.height
            } completion: { _ in
                self.errorBannerView.removeFromSuperview()
            }
        }
    }
}

// MARK: Selector methods for UIButton.
@objc
private extension HomeViewController {
    func searchButtonDidTap() {
        viewModel.displaySearchLocationView(isSearchingArrival: true)
    }
    
    func cancelButtonDidTap() {
        cancelAction()
    }
    
    func startSearchButtonDidTap() {
        viewModel.displaySearchLocationView(isSearchingArrival: false)
    }
    
    func arrivalSearchButtonDidTap() {
        viewModel.displaySearchLocationView(isSearchingArrival: true)
    }
    
    func cancelStartNavigationButtonDidTap() {
        cancelAction()
        mainSearchContainerView.isHidden = false
        locationContainerView.isHidden = true
        startSearchButton.setTitle("Votre position", for: .normal)
    }
    
    func swapLocationButtonDidTap() {
        swapAnnotations()
        switch searchLocationState {
        case .emptyStart:
            viewModel.selectedPlacemarkStart = viewModel.selectedPlacemarkArrival ?? Placemark(name: "", coordinate: CLLocationCoordinate2D())
            viewModel.selectedPlacemarkArrival = Placemark(name: "Votre position", coordinate: LocationManager.shared.currentLocation.coordinate)
            startSearchButton.setTitle(viewModel.selectedPlacemarkStart?.name, for: .normal)
            arrivalSearchButton.setTitle(viewModel.selectedPlacemarkArrival?.name, for: .normal)
            directionButton.changeStyle(.inProgress)
            directionButton.isEnabled = false
        case .emptyArrival:
            viewModel.selectedPlacemarkArrival = viewModel.selectedPlacemarkStart ?? Placemark(name: "", coordinate: CLLocationCoordinate2D())
            viewModel.selectedPlacemarkStart = Placemark(name: "Votre position", coordinate: LocationManager.shared.currentLocation.coordinate)
            arrivalSearchButton.setTitle(viewModel.selectedPlacemarkArrival?.name, for: .normal)
            startSearchButton.setTitle(viewModel.selectedPlacemarkStart?.name, for: .normal)
            directionButton.changeStyle(.start)
            directionButton.isEnabled = true
        case .bothFilled:
            let selectedPlacemarkStart = viewModel.selectedPlacemarkStart ?? Placemark(name: "", coordinate: CLLocationCoordinate2D())
            viewModel.selectedPlacemarkStart = viewModel.selectedPlacemarkArrival
            startSearchButton.setTitle(viewModel.selectedPlacemarkStart?.name, for: .normal)
            viewModel.selectedPlacemarkArrival = selectedPlacemarkStart
            arrivalSearchButton.setTitle(selectedPlacemarkStart.name, for: .normal)
        }
    }
    
    func currentUserLocationButtonDidTap() {
        centerCameraToUserCurrentLocation()
        if !cancellables.isEmpty {
            cancellables.forEach({ $0.cancel() })
            cancellables.removeAll()
        }
    }
    
    func directionButtonDidTap(sender: DirectionButton) {
        if sender.style == .itinerary {
            directionButton.isHidden = true
            viewModel.calculateRouteWithApi()
        } else {
            viewModel.displayMapboxNavigation()
        }
    }
}

private extension Selector {
    static let searchButtonDidTapAction = #selector(HomeViewController.searchButtonDidTap)
    static let cancelButtonDidTapAction = #selector(HomeViewController.cancelButtonDidTap)
    static let startSearchButtonDidTapAction = #selector(HomeViewController.startSearchButtonDidTap)
    static let arrivalSearchButtonDidTapAction = #selector(HomeViewController.arrivalSearchButtonDidTap)
    static let cancelStartNavigationButtonDidTapAction = #selector(HomeViewController.cancelStartNavigationButtonDidTap)
    static let swapLocationButtonDidTapAction = #selector(HomeViewController.swapLocationButtonDidTap)
    static let currentUserLocationButtonDidTapAction = #selector(HomeViewController.currentUserLocationButtonDidTap)
    static let directionButtonDidTapAction = #selector(HomeViewController.directionButtonDidTap)
}
