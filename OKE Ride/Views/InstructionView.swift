import SwiftUI

struct InstructionView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Use the App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)


                Text("1. Sign in to your account or register if you're new.")
                Text("2. Locate available scooters on the map.")
                Text("3. Use the QR scanner or type code to unlock a scooter.")
                Text("4. Enjoy your ride!")
                // Include further instructions as needed.
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Instructions", displayMode: .inline)
    }
}
}
