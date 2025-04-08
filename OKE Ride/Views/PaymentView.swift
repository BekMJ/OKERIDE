import SwiftUI

struct PaymentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Pay for Your Rental")
                .font(.headline)
            
            ApplePayButton()
                .frame(height: 50)
                .onTapGesture {
                    PaymentHandler.shared.startPayment()
                }
            
            Spacer()
        }
        .padding()
    }
}

