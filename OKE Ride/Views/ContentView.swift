import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var scooterVM: ScooterViewModel

    var body: some View {
        Group {
            if authViewModel.user == nil {
                SignInView()
            } else {
                HomeView()
                    .onAppear {
                        // Connect to MQTT broker
                        MQTTManager.shared.connect()
                        // Subscribe to all scooter status topics
                        MQTTManager.shared.subscribe(to: "scooter/+/status")
                        // Preload the 3D scooter scene for fast rendering
                        TransparentView.preloadScene()
                    }
            }
        }
        .onAppear {
            // Check if a user is already signed in
            authViewModel.user = Auth.auth().currentUser
        }
    }
}
