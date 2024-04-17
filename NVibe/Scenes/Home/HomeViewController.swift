//
//  HomeViewController.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import UIKit
import MapboxMaps
import Combine
import MapboxNavigation

class HomeViewController: UIViewController {
    weak var homeCoordinator: HomeCoordinator?
    private var service = HomeService()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.coordinatesPublisher
            .sink { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print("OUUU")
                                print(error)
                            }
                        } receiveValue: { direction in
                            print(direction)
                        }
                        .store(in: &cancellables)

     let mapView = MapView(frame: view.bounds)
        let cameraOptions = CameraOptions(center:
            CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0),
            zoom: 2, bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D()
        mapView.viewport.makeFollowPuckViewportState()
        view.addSubview(mapView)

    }
}
