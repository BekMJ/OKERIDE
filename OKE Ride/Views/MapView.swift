import SwiftUI
import MapKit

// MARK: - Custom Button Style for Scooter Annotation
struct ScooterAnnotationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label .padding(10)
        .background(configuration.isPressed ?
                    Color.black : Color.white) .clipShape(Circle()) .shadow(radius: 2) } }

enum MapAnnotationItem: Identifiable {
    case scooter(Scooter)
    case user(location: CLLocationCoordinate2D)


var id: String {
    switch self {
    case .scooter(let scooter):
        return scooter.id ?? UUID().uuidString
    case .user:
        return "userLocation"
    }
}

var coordinate: CLLocationCoordinate2D {
    switch self {
    case .scooter(let scooter):
        return CLLocationCoordinate2D(latitude: scooter.latitude, longitude: scooter.longitude)
    case .user(let location):
        return location
    }
}
}

struct MapView: View {
    @Binding var scooters: [Scooter]
    @Binding var region: MKCoordinateRegion
    var userLocation: CLLocationCoordinate2D? // Closure to be called when a scooter is tapped.
    var onScooterSelected: (Scooter) -> Void


var body: some View {
    let annotations = scooters.map { MapAnnotationItem.scooter($0) } +
        (userLocation != nil ? [MapAnnotationItem.user(location: userLocation!)] : [])
    
    return Map(coordinateRegion: $region, annotationItems: annotations) { item in
        MapAnnotation(coordinate: item.coordinate) {
            Group {
                if case .scooter(let scooter) = item {
                    Button(action: {
                        onScooterSelected(scooter)
                    }) {
                        Image("scooterIcon")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(ScooterAnnotationButtonStyle())
                } else if case .user = item {
                    ZStack {
                        PulsingDot()
                        Image(systemName: "location.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.blue)
                            .padding(6)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
            }
        }
    }
    .cornerRadius(20)
}
}
