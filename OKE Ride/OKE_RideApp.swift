import SwiftUI
import Firebase

@main
struct OKE_RideApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var scooterVM = ScooterViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(scooterVM)
        }
    }
}
