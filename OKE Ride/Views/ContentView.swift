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
                // Directly show HomeView instead of using a TabView
                HomeView()
                    .onAppear {
                        scooterVM.fetchScooters()
                    }
            }
        }
        .onAppear {
            // Check if a user is already signed in.
            authViewModel.user = Auth.auth().currentUser
        }
    }
}
