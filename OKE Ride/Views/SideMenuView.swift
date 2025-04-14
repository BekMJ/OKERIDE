import SwiftUI
import MapKit

// MARK: - Side Menu Views

struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    var username: String {
        if let user = authViewModel.user {
            if let displayName = user.displayName, !displayName.isEmpty {
                return displayName
            } else if let email = user.email {
                // Get the part before the "@" in the email.
                return email.split(separator: "@").first.map(String.init) ?? "User"
            }
        }
        return "User"
    }

var body: some View {
    // Wrap the side menu in a NavigationView so that NavigationLinks work.
    NavigationView {
        VStack(alignment: .leading, spacing: 20) {
            // Header with logo and greeting
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Welcome!")
                        .font(.headline)
                    Text(username)
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .padding(.bottom, 24)
            
            // Navigation Links for menu items
            NavigationLink(destination: SettingsView()) {
                MenuRow(title: "Settings", icon: Image(systemName: "gearshape.fill"), action: {})
            }
            NavigationLink(destination: InstructionView()) {
                MenuRow(title: "Instructions", icon: Image(systemName: "questionmark.circle.fill"), action: {})
            }
            NavigationLink(destination: PaymentView()) {
                MenuRow(title: "Payment", icon: Image(systemName: "creditcard.fill"), action: {})
            }
            
            Spacer()
            
            Divider()
                .padding(.vertical, 10)
            
            // Log Out Button
            Button(action: {
                authViewModel.signOut()
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "arrow.backward.circle.fill")
                    Text("Log Out")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.top, 44)
        .navigationBarHidden(true)
    }
}
}

// Reusable MenuRow used inside SideMenuView.

struct MenuRow: View {
    let title: String
    let icon: Image
    let action: () -> Void


var body: some View {
    // Although the action isn't triggered by NavigationLink,
    // we reuse this view for styling.
    HStack(spacing: 16) {
        icon
            .font(.system(size: 20))
            .foregroundColor(.blue)
        Text(title)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.primary)
    }
    .padding(.vertical, 8)
    .padding(.horizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(Rectangle())
}
}
