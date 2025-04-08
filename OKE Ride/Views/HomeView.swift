import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scooterVM: ScooterViewModel
    @StateObject var locationManager = LocationManager()
    
    @State private var showQRScanner = false
    @State private var showUnlockPopup = false
    @State private var scannedScooter: Scooter? = nil
    @State private var showSideMenu = false

    var body: some View {
        ZStack {
            // Full-screen map with scooter annotations and a user location marker.
            MapView(scooters: $scooterVM.scooters, region: $locationManager.region)
                .edgesIgnoringSafeArea(.all)
            
            // Side Menu button (hamburger icon)
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            showSideMenu.toggle()
                        }
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

            // Floating scan button at the bottom center.
            VStack {
                Spacer()
                Button(action: {
                    showQRScanner = true
                }) {
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
            
            // Side Menu Overlay
            if showSideMenu {
                SideMenuView(showSideMenu: $showSideMenu)
                    .transition(.move(edge: .leading))
            }
        }
        .sheet(isPresented: $showQRScanner) {
            // Present the QR scanner screen with our custom onScan closure.
            QRScannerScreen { scannedID in
                // Attempt to find the scooter using the scanned code.
                if let scooter = scooterVM.scooters.first(where: { $0.id == scannedID }) {
                    scannedScooter = scooter
                    showUnlockPopup = true
                }
                showQRScanner = false
            }
        }
        // Pop-up alert for unlocking the scooter.
        .alert(isPresented: $showUnlockPopup) {
            Alert(
                title: Text("Unlock Scooter"),
                message: Text("Do you want to unlock \(scannedScooter?.name ?? "this scooter")?"),
                primaryButton: .default(Text("Unlock"), action: {
                    if let scooter = scannedScooter {
                        scooterVM.unlockScooter(scooter) { success in
                            // Handle success/failure as needed.
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}
