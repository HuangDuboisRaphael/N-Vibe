//
//  LocationManager.swift
//  NVibe
//
//  Created by Raphaël Huang-Dubois on 17/04/2024.
//

import Combine
import CoreLocation

/// Singleton class to ask location permission and store the user's current location.
final class LocationManager: NSObject {
    var currentLocation = CLLocation()
    var coordinatePublisher = PassthroughSubject<Void, Error>()
    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        requestLocationUpdates()
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.delegate = self
        return manager
    }()
    
    private func requestLocationUpdates() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            deniedLocationAccessPublisher.send()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            deniedLocationAccessPublisher.send()
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        coordinatePublisher.send(())
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinatePublisher.send(completion: .failure(error))
    }
}
