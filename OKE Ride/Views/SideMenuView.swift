import SwiftUI

struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                // Navigate to Settings
            }) {
                Text("Settings")
                    .padding(.vertical, 10)
            }
            Button(action: {
                // Navigate to Instructions
            }) {
                Text("Instructions")
                    .padding(.vertical, 10)
            }
            Button(action: {
                // Navigate to Payment
            }) {
                Text("Payment")
                    .padding(.vertical, 10)
            }
            
            Spacer()
            
            // Log Out Button
            Button(action: {
                authViewModel.signOut()
            }) {
                Text("Log Out")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .foregroundColor(.red)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: 250)
        .padding()
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}
