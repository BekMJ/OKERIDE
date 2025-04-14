import Foundation
import PassKit
import SwiftUI

class PaymentHandler: NSObject, ObservableObject, PKPaymentAuthorizationControllerDelegate {
    static let shared = PaymentHandler()
    var paymentController: PKPaymentAuthorizationController?


func startPayment() {
    let paymentRequest = PKPaymentRequest()
    paymentRequest.merchantIdentifier = "your.test.merchant.id" // Use your test Merchant ID for the sandbox.
    paymentRequest.supportedNetworks = [.visa, .masterCard, .amex]
    paymentRequest.merchantCapabilities = .threeDSecure
    paymentRequest.countryCode = "US"
    paymentRequest.currencyCode = "USD"
    
    paymentRequest.paymentSummaryItems = [
        PKPaymentSummaryItem(label: "Scooter Rental", amount: NSDecimalNumber(string: "5.00"))
    ]
    
    if PKPaymentAuthorizationController.canMakePayments() {
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present { presented in
            if presented {
                print("Payment authorization presented.")
            } else {
                print("Failed to present payment authorization.")
            }
        }
    } else {
        print("Apple Pay is not available on this device.")
        // Fallback simulation
        simulatePaymentSuccess()
    }
}

func simulatePaymentSuccess() {
    // This method simulates a successful payment for testing purposes.
    print("Simulated payment successful!")
}

func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss {
        print("Payment controller dismissed.")
    }
}

func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    // Simulate processing payment.
    print("Payment authorized. Simulating payment success...")
    let status: PKPaymentAuthorizationStatus = .success
    completion(PKPaymentAuthorizationResult(status: status, errors: nil))
}
}
