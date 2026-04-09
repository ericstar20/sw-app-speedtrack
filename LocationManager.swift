import Combine
import CoreLocation
import Foundation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var speed: Double = 0.0
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Locating..."

    private var lastGeocode: Date = .distantPast

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        authStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        DispatchQueue.main.async {
            self.authStatus = status
            if status == .denied || status == .restricted {
                self.locationName = "Location Permission Needed"
                self.speed = 0
            }
        }

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationName = "Location Unavailable"
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let rawSpeed = max(location.speed, 0)
        DispatchQueue.main.async {
            self.speed = rawSpeed
        }

        guard Date().timeIntervalSince(lastGeocode) > 30, !geocoder.isGeocoding else { return }
        lastGeocode = Date()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }

            let resolvedName: String
            if let place = placemarks?.first {
                resolvedName = place.locality ?? place.subLocality ?? place.administrativeArea ?? "Unknown Location"
            } else {
                resolvedName = error != nil ? "Location Unavailable" : "Unknown Location"
            }

            DispatchQueue.main.async {
                self.locationName = resolvedName
            }
        }
    }
}
