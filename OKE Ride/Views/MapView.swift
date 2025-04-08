import SwiftUI
import MapKit

struct MapView: View {
    @Binding var scooters: [Scooter]
    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: scooters) { scooter in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: scooter.latitude, longitude: scooter.longitude)) {
                Image("scooterIcon") // Custom scooter image asset
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(scooter.isAvailable ? .green : .red)
            }
        }
        
        .overlay(
            // User location marker: a blue icon at the center
            Image(systemName: "location.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.blue)
                .padding(6)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 3),
            alignment: .center
        )
        .cornerRadius(20)
    }
}

