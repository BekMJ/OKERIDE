import SwiftUI

struct QRScannerScreen: View {
    var onScan: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var manualCode: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // The camera-based QR scanner.
                QRCodeScannerView { scannedID in
                    onScan(scannedID)
                    presentationMode.wrappedValue.dismiss()
                }
                .edgesIgnoringSafeArea(.all)
                
                // Manual code entry section.
                VStack(spacing: 8) {
                    Text("Or enter the scooter code manually:")
                        .font(.headline)
                    HStack {
                        TextField("Enter code", text: $manualCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Submit") {
                            DispatchQueue.main.async {
                                onScan(manualCode)
                                presentationMode.wrappedValue.dismiss() } }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                .background(Color.white.opacity(0.9))
            }
            .navigationBarTitle("Scan QR Code", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
