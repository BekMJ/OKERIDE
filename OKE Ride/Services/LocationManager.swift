import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()


// Set the default region to your desired coordinate.
@Published var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 35.23116712907508, longitude: -97.47748324856035),
    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
)
@Published var userLocation: CLLocationCoordinate2D? = nil

override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
}

// Update only the userLocation so that your map's region is not reset.
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
}
}
