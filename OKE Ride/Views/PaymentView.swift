import SwiftUI

struct PaymentView: View {
    enum PaymentType: String, CaseIterable, Identifiable {
        case applePay = "Apple Pay"
        case card = "Credit/Debit Card"
        var id: String { rawValue }
    }

    @AppStorage("paymentType") private var paymentTypeRaw: String = PaymentType.applePay.rawValue
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvv = ""
    @State private var showMockAlert = false

    private var paymentType: PaymentType {
        PaymentType(rawValue: paymentTypeRaw) ?? .applePay
    }

    var body: some View {
        Form {
            Section(header: Text("Select Payment Method")) {
                Picker("Method", selection: $paymentTypeRaw) {
                    ForEach(PaymentType.allCases) { method in
                        Text(method.rawValue).tag(method.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            if paymentType == .applePay {
                Section {
                    ApplePayButton()
                        .frame(height: 50)
                        .onTapGesture {
                            if PaymentHandler.shared.useMockPayment {
                                showMockAlert = true
                            }
                            PaymentHandler.shared.startPayment { success in
                                if success {
                                    print("✅ Payment succeeded")
                                    // handle post-payment actions
                                } else {
                                    print("❌ Payment failed or cancelled")
                                }
                            }
                        }
                }
            } else {
                Section(header: Text("Card Details")) {
                    TextField("Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    HStack {
                        TextField("MM/YY", text: $expiry)
                            .keyboardType(.numbersAndPunctuation)
                        TextField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                    }
                    Button("Save Card") {
                        // Persist or secure card data
                        print("Card saved: \(cardNumber)")
                    }
                }
            }
        }
        .navigationTitle("Payment Options")
        .alert("🛠️ Mock Payment", isPresented: $showMockAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This is a simulated payment flow.")
        }
    }
}

