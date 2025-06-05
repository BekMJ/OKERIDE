// MQTTManager.swift
// Handles all MQTT communication with the scooter network.

import Foundation
import CocoaMQTT
import Combine

/// Manages the MQTT connection, subscriptions, and message publishing.
class MQTTManager: NSObject, ObservableObject {
    // MARK: - Shared Instance
    static let shared = MQTTManager()

    // MARK: - Public Publisher
    /// Emits (topic, payload) tuples for any incoming messages.
    let messagePublisher = PassthroughSubject<(topic: String, payload: String), Never>()

    // MARK: - Internal
    private var mqttClient: CocoaMQTT!
    private let host = "your.mqtt.broker.com"    // ← Replace with your broker address
    private let port: UInt16 = 1883               // ← Replace if different
    private let username: String? = nil           // ← Optional: set if your broker requires auth
    private let password: String? = nil

    private override init() {
        super.init()
        let clientID = "iOS-Client-" + UUID().uuidString
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqttClient.username = username
        mqttClient.password = password
        mqttClient.keepAlive = 60
        mqttClient.autoReconnect = true
        mqttClient.delegate = self
    }

    // MARK: - Connection
    func connect() {
        mqttClient.connect()
    }

    func disconnect() {
        mqttClient.disconnect()
    }

    // MARK: - Subscriptions
    func subscribe(to topic: String) {
        mqttClient.subscribe(topic, qos: .qos1)
    }

    func unsubscribe(from topic: String) {
        mqttClient.unsubscribe(topic)
    }

    // MARK: - Publishing
    func publish(_ topic: String, message: String) {
        mqttClient.publish(topic, withString: message, qos: .qos1)
    }

    /// Helper to send an unlock command for a specific scooter.
    func publishUnlockCommand(for scooterID: String) {
        let topic = "scooter/\(scooterID)/command"
        let payload = "{ \"action\": \"unlock\" }"
        publish(topic, message: payload)
    }
}

// MARK: - CocoaMQTTDelegate
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("✅ MQTT did connect to \(host):\(port)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("✅ MQTT connected with ack: \(ack)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📤 Published [\(message.topic)]: \(message.string ?? "") (id: \(id))")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("📤 Publish ack for id \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let topic = message.topic
        let payload = message.string ?? ""
        print("📥 Received [\(topic)]: \(payload)")
        messagePublisher.send((topic: topic, payload: payload))
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("✅ Subscribed to topics: \(success), failed: \(failed)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("⚠️ Unsubscribed from topics: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("↔️ MQTT ping")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("↔️ MQTT pong")
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("⚠️ MQTT disconnected: \(err?.localizedDescription ?? "no error")")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}
