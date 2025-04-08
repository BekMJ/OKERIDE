import SwiftUI
import PassKit

struct ApplePayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> PKPaymentButton {
        return PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
    }
    
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
}
