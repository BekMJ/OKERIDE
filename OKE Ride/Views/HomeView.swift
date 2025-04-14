import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scooterVM: ScooterViewModel
    @StateObject var locationManager = LocationManager()


@State private var showQRScanner = false
@State private var showUnlockPopup = false
@State private var scannedScooter: Scooter? = nil
@State private var showSideMenu = false
@State private var selectedScooter: Scooter? = nil  // For displaying details

var body: some View {
    ZStack {
        // Map view (remains fully interactive)
        MapView(
            scooters: $scooterVM.scooters,
            region: $locationManager.region,
            userLocation: locationManager.userLocation,
            onScooterSelected: { scooter in
                // When tapped, set selectedScooter to display the detail overlay.
                selectedScooter = scooter
            }
        )
        .edgesIgnoringSafeArea(.all)
        
        // Top-left side menu toggle button.
        VStack {
            HStack {
                Button(action: {
                    withAnimation { showSideMenu.toggle() }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .resizable()
                        .frame(width: 25, height: 20)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
        
        // Bottom center floating scan button.
        VStack {
            Spacer()
            Button(action: { showQRScanner = true }) {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.bottom, 40)
        }
        
        // Side Menu overlay.
        if showSideMenu {
            ZStack(alignment: .leading) {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { withAnimation { showSideMenu = false } }
                SideMenuView(showSideMenu: $showSideMenu)
                    .frame(width: 300)
                    .transition(.move(edge: .leading))
            }
        }
        
        // Custom bottom overlay for scooter details.
        if let scooter = selectedScooter {
            VStack {
                Spacer()
                ScooterDetailView(scooter: scooter, userLocation: locationManager.userLocation)
                    .frame(height: 300)      // Adjust height as needed.
                    .background(Color.white) // Background for the overlay.
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom))
                    // Optional: add a drag gesture to dismiss the overlay.
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    withAnimation {
                                        selectedScooter = nil
                                    }
                                }
                            }
                    )
            }
            // Allow interaction with the map above the overlay.
            .allowsHitTesting(true)
        }
    }
    .onAppear {
        scooterVM.fetchScooters()
    }
    .sheet(isPresented: $showQRScanner) {
        QRScannerScreen { scannedID in
            if let scooter = scooterVM.scooters.first(where: { $0.id == scannedID }) {
                scannedScooter = scooter
                showUnlockPopup = true
            }
            showQRScanner = false
        }
    }
    .alert(isPresented: $showUnlockPopup) {
        Alert(
            title: Text("Pay & Unlock Scooter"),
            message: Text("Do you want to pay & unlock \(scannedScooter?.name ?? "this scooter")?"),
            primaryButton: .default(Text("Pay & Unlock"), action: {
                PaymentHandler.shared.startPayment()
                if let scooter = scannedScooter {
                    scooterVM.unlockScooter(scooter) { success in
                        print(success ? "Scooter unlocked (simulated)" : "Unlock failed (simulated)")
                    }
                }
            }),
            secondaryButton: .cancel()
        )
    }
}
}
