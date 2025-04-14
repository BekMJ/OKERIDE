import SwiftUI
import CoreLocation

struct BatteryView: View {
    var batteryLevel: Int


var body: some View {
    HStack(spacing: 2) {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: 40, height: 20)
                .foregroundColor(Color.gray.opacity(0.3))
            Rectangle()
                .frame(width: CGFloat(batteryLevel) * 40 / 100, height: 20)
                .foregroundColor(batteryLevel < 20 ? .red : .green)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.black, lineWidth: 1)
        )
        Rectangle() // Battery cap.
            .frame(width: 4, height: 10)
            .foregroundColor(.black)
    }
}
}

struct ScooterDetailView: View {
    let scooter: Scooter
    let userLocation: CLLocationCoordinate2D?


// Use actual battery level if available; otherwise, simulate.
var batteryLevel: Int {
    scooter.batteryLevel   // Assuming batteryLevel is optional in your model.
}

var priceRange: String { "$3 an hour" }

var distanceInMiles: Double? {
    if let userLocation = userLocation {
        let scooterLoc = CLLocation(latitude: scooter.latitude, longitude: scooter.longitude)
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distanceMeters = scooterLoc.distance(from: userLoc)
        return distanceMeters / 1609.34
    }
    return nil
}

var distanceText: String {
    if let miles = distanceInMiles {
        return String(format: "%.1f miles", miles)
    }
    return "Unknown"
}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with scooter icon and title.
            HStack {
                Image("scooterIcon")
                    .resizable()
                    .frame(width: 50, height: 50)
                Text(scooter.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
            }
            Divider()
            // Battery display.
            HStack {
                Text("Battery:")
                    .font(.headline)
                    .foregroundColor(.black)
                BatteryView(batteryLevel: batteryLevel)
                Text("\(batteryLevel)%")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            // Distance in miles.
            HStack {
                Text("Distance from you:")
                    .font(.headline)
                    .foregroundColor(.black)
                Text(distanceText)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
            }
            // Price range.
            HStack {
                Text("Price Range:")
                    .font(.headline)
                    .foregroundColor(.black)
                Text(priceRange)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}
