//
//  LocationHelper.swift
//  WalkieTalkie
//
//  Created by Iaroslav Kosarev on 14.11.22.
//

import CoreLocation

protocol LocationHelperDelegate: AnyObject {
    func updatedDistanceBetweenUsers(newValue: Double)
    func didUpdateLocation(lat: Double, lon: Double)
}

class LocationHelper: NSObject {
    let locationManager = CLLocationManager()
    private var locationOfPeer: CLLocation?
    weak var delegate: LocationHelperDelegate?

    deinit {
        locationManager.stopUpdatingLocation()
    }

    func startLoading() {
        locationManager.delegate = self
        locationManager.distanceFilter = 5

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopLoading() {
        locationManager.stopUpdatingLocation()
    }

    func updatePeerLocation(lat: Double, lon: Double) {
        locationOfPeer = CLLocation(latitude: lat, longitude: lon)
        updateDistance()
    }

    private func updateDistance() {
        guard let location = locationManager.location else {
            return
        }
        delegate?.didUpdateLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        if let locationOfPeer = locationOfPeer {
            let distance = locationOfPeer.distance(from: location)
            delegate?.updatedDistanceBetweenUsers(newValue: distance)
        }
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateDistance()
    }
}
