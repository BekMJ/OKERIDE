import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scooterVM: ScooterViewModel
    @StateObject var locationManager = LocationManager()
    @State private var showInvalidCodeAlert = false


@State private var showQRScanner = false
@State private var showUnlockPopup = false
@State private var scannedScooter: Scooter? = nil
@State private var showSideMenu = false
@State private var selectedScooter: Scooter? = nil  // For displaying details
    @State private var showDetail = false
    
    // 1) Enum to represent which alert to show
    enum ActiveAlert: Identifiable {
        case unlock, invalid
        var id: ActiveAlert { self }
    }
    
var body: some View {
    ZStack {
        // Map view (remains fully interactive)
        RestrictionMapView(
          scooters: $scooterVM.scooters,
          region:   $locationManager.region,
          userLocation: locationManager.userLocation,
          onScooterSelected: { scooter in
              scannedScooter = scooter
              showUnlockPopup = true
              selectedScooter = scooter
              showDetail = true
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
        
       
    }
    .onAppear {
        scooterVM.fetchScooters()
        
    }

    .sheet(isPresented: $showQRScanner) {
      QRScannerScreen { rawCode in
        let code = rawCode
          .trimmingCharacters(in: .whitespacesAndNewlines)
          .lowercased()

        if let scooter = scooterVM.scooters.first(
             where: { $0.id?.lowercased() == code }
           ) {
          scannedScooter   = scooter
          showUnlockPopup = true
        } else {
          showInvalidCodeAlert = true
        }
        showQRScanner = false
      }
    }
    .alert(isPresented: $showUnlockPopup) {
      Alert(
        title: Text("Pay & Unlock Scooter"),
        message: Text("Do you want to pay & unlock \(scannedScooter?.name ?? "this scooter")?"),
        primaryButton: .default(Text("Pay & Unlock")) {
          // kick off the payment (mock or real) and wait for its result
          DispatchQueue.main.async {
            PaymentHandler.shared.startPayment { success in
              if success, let scooter = scannedScooter {
                scooterVM.unlockScooter(scooter) { unlocked in
                  print(unlocked ? "✅ Unlocked" : "❌ Unlock failed")
                }
              } else {
                print("❌ Payment failed or cancelled")
              }
            }
          }
        },
        secondaryButton: .cancel()
      )
    }

    .alert(isPresented: $showInvalidCodeAlert) {
      Alert(
        title: Text("Invalid Code"),
        message: Text("No scooter found with that code. Please try again."),
        dismissButton: .default(Text("OK"))
      )
    }
    .sheet(isPresented: $showDetail, onDismiss: {
        selectedScooter = nil
      }) {
      if let scooter = selectedScooter {
        ScooterDetailView(
          scooter: scooter,
          userLocation: locationManager.userLocation
        )
        .presentationDetents([.medium, .large])   // requires iOS 16+
      }
    }
}
}


