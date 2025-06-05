//
//  ScooterInteractionManager.swift
//  OKE Ride
//
//  Created by NPL-Weng on 5/15/25.
//


import Foundation
import CoreBluetooth
import NearbyInteraction
import Combine
import UIKit

/// Manages BLE connection and UWB (Nearby Interaction) session with a scooter
class ScooterInteractionManager: NSObject, ObservableObject {
    // MARK: - Published
    @Published var distance: Float?          // in meters
    @Published var direction: simd_float3?   // unit vector from user to scooter
    @Published var isSessionActive = false

    // MARK: - BLE Properties
    private var centralManager: CBCentralManager!
    private var scooterPeripheral: CBPeripheral?
    private var discoveryTokenCharacteristic: CBCharacteristic?

    // Replace with your scooter BLE service & characteristic UUIDs
    private let scooterServiceUUID          = CBUUID(string: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    private let tokenCharacteristicUUID     = CBUUID(string: "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY")

    // MARK: - UWB Properties
    private var niSession: NISession?
    private var pendingToken: NIDiscoveryToken?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - Public API
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [scooterServiceUUID], options: nil)
    }

    func connect(to peripheral: CBPeripheral) {
        scooterPeripheral = peripheral
        scooterPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    // Call after BLE connection and token exchange
    private func startUWBSession(with token: NIDiscoveryToken) {
        let config = NINearbyPeerConfiguration(peerToken: token)
        niSession = NISession()
        niSession?.delegate = self
        niSession?.run(config)
        isSessionActive = true
    }

    func invalidateSession() {
        niSession?.invalidate()
        isSessionActive = false
        distance = nil
        direction = nil
    }
}

// MARK: - CBCentralManagerDelegate
extension ScooterInteractionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            // Handle unsupported state
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        // Found scooter peripheral
        connect(to: peripheral)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([scooterServiceUUID])
    }
}

// MARK: - CBPeripheralDelegate
extension ScooterInteractionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for svc in services where svc.uuid == scooterServiceUUID {
            peripheral.discoverCharacteristics([tokenCharacteristicUUID], for: svc)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let chars = service.characteristics else { return }
        if let tokenChar = chars.first(where: { $0.uuid == tokenCharacteristicUUID }) {
            discoveryTokenCharacteristic = tokenChar
            peripheral.readValue(for: tokenChar)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard characteristic.uuid == tokenCharacteristicUUID,
              let data = characteristic.value else { return }
        // Convert data to NIDiscoveryToken
        if let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            pendingToken = token
            startUWBSession(with: token)
        }
    }
}

// MARK: - NISessionDelegate
extension ScooterInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let obj = nearbyObjects.first else { return }
        distance = obj.distance
        direction = obj.direction
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        isSessionActive = false
    }
}
