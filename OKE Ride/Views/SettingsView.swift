//
//  SettingsView.swift
//  OKE Ride
//
//  Created by NPL-Weng on 4/8/25.
//
import SwiftUI
struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)
                    .padding(.top, 16)
            Toggle("Enable Notifications", isOn: .constant(true))
                .padding()
            Toggle("Dark Mode", isOn: .constant(false))
                .padding()
            // Add additional settings controls as needed.
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}
}
