import PassKit

class PaymentHandler: NSObject, PKPaymentAuthorizationControllerDelegate {
  static let shared = PaymentHandler()
  private var controller: PKPaymentAuthorizationController?
  private var completion: ((Bool) -> Void)?
  
  /// When true, we skip Apple Pay and immediately succeed (for local dev).
  var useMockPayment: Bool = {
    #if DEBUG
    return true
    #else
    return false
    #endif
  }()

  func startPayment(amount: NSDecimalNumber = 1.00,
                    label: String = "Scooter Unlock",
                    merchantId: String = "merchant.com.yourCompany.okeRide",
                    completion: @escaping (Bool) -> Void) {
    self.completion = completion

    // === MOCK PATH ===
    if useMockPayment {
      // Simulate a short delay, then succeed
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        print("💰 [MOCK] Payment succeeded")
        completion(true)
      }
      return
    }

    // === REAL APPLE PAY PATH ===
    let request = PKPaymentRequest()
    request.merchantIdentifier   = merchantId
    request.countryCode          = "US"
    request.currencyCode         = "USD"
    request.merchantCapabilities = .capability3DS
    request.supportedNetworks    = [.visa, .masterCard, .amex]
    request.paymentSummaryItems  = [
      PKPaymentSummaryItem(label: label, amount: amount)
    ]

    controller = PKPaymentAuthorizationController(paymentRequest: request)
    controller?.delegate = self
    controller?.present { success in
      if !success {
        print("❌ Payment sheet failed to present")
        completion(false)
      }
    }
  }

  // MARK: Delegate callbacks
  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      handler handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
    handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
    completion?(true)
  }

  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss { }
  }
}
