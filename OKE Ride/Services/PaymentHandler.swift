import Foundation
import PassKit
import SwiftUI

class PaymentHandler: NSObject, ObservableObject, PKPaymentAuthorizationControllerDelegate {
    static let shared = PaymentHandler()
    var paymentController: PKPaymentAuthorizationController?

    func startPayment() {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "your.merchant.id" // Replace with your Merchant ID
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
                if !presented {
                    print("Failed to present Apple Pay authorization.")
                }
            }
        } else {
            print("Apple Pay is not available on this device.")
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            // Additional logic after dismissal, if needed.
        }
    }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                          didAuthorizePayment payment: PKPayment,
                                          completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Process payment (e.g., send to your backend) and return success or error.
        let status: PKPaymentAuthorizationStatus = .success
        completion(PKPaymentAuthorizationResult(status: status, errors: nil))
    }
}
