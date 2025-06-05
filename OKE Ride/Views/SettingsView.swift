import SwiftUI

struct SettingsView: View {
    // Persist settings across launches
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("distanceUnit") private var distanceUnit: String = "Miles"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Appearance", systemImage: "paintbrush")) {
                    Toggle(isOn: $darkModeEnabled) {
                        Label("Dark Mode", systemImage: darkModeEnabled ? "moon.fill" : "sun.max.fill")
                    }
                }

                Section(header: Label("Preferences", systemImage: "gear")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                    }

                    Picker(selection: $distanceUnit, label: Label("Distance Unit", systemImage: "ruler")) {
                        Text("Miles").tag("Miles")
                        Text("Kilometers").tag("Kilometers")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Label("About", systemImage: "info.circle")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        // Apply dark mode setting dynamically
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}
