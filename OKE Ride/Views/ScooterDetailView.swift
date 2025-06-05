import SwiftUI
import CoreLocation

// MARK: - Circular Battery View
struct CircularBatteryView: View {
    var batteryLevel: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 6)
                .opacity(0.3)
                .foregroundColor(.secondary)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(batteryLevel, 0), 100)) / 100)
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotation(Angle(degrees: -90))
                .foregroundColor(batteryLevel < 20 ? .red : .green)
            Text("\(batteryLevel)%")
                .font(.caption)
                .bold()
        }
    }
}

// MARK: - Scooter Detail Sheet
struct ScooterDetailView: View {
    @EnvironmentObject var scooterVM: ScooterViewModel
    let scooter: Scooter
    let userLocation: CLLocationCoordinate2D?

    @State private var showMockAlert = false

    var batteryLevel: Int { scooter.batteryLevel }
    var priceRange: String { "$3 an hour" }
    var distanceInMiles: Double? {
        guard let userLoc = userLocation else { return nil }
        let scooterLoc = CLLocation(latitude: scooter.latitude, longitude: scooter.longitude)
        let userLocCL = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        return scooterLoc.distance(from: userLocCL) * 0.000621371
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle (visual only)
            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 40, height: 6)
                .padding(.top, 8)
                .padding(.bottom, 4)

            // Sheet content
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    CircularBatteryView(batteryLevel: batteryLevel)
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading) {
                        Text("Battery")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(batteryLevel)%")
                            .font(.headline)
                    }
                    Spacer()
                }

                TransparentView()
                    .frame(height: 200)
                    .cornerRadius(12)

                HStack {
                    Image(systemName: "scooter")
                        .font(.title2)
                    Text("Scooter Details")
                        .font(.headline)
                    Spacer()
                }

                HStack {
                    if let dist = distanceInMiles {
                        Text(String(format: "%.2f mi away", dist))
                            .font(.subheadline)
                    }
                    Spacer()
                }
                Text(priceRange)
                    .font(.subheadline)

                Text("• Charger Port: Type-C")
                Text("• Usage Time: Up to 2 hrs")

                Button(action: {
                    // 1) Kick off payment, handle the result in the completion closure
                    PaymentHandler.shared.startPayment(
                        amount: NSDecimalNumber(string: "5.00"),
                        label: "Scooter Unlock",
                        merchantId: "merchant.com.yourCompany.okeRide"
                    ) { success in
                        if success {
                            print("✅ Payment succeeded – unlocking scooter via MQTT")
                            scooterVM.unlockScooterViaMQTT(scooter)
                        } else {
                            print("❌ Payment failed – not unlocking")
                            // TODO: present an alert to the user if you like
                        }
                    }
                }) {
                    Text("Unlock Scooter")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .alert("🛠️ Mock Payment", isPresented: $showMockAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This is a simulated payment flow.")
        }
    }
}
