// MQTTManager.swift
// Handles all MQTT communication with the scooter network.

import Foundation
import CocoaMQTT
import Combine

/// Manages the MQTT connection, subscriptions, and message publishing.
class MQTTManager: NSObject, ObservableObject {
    //    MARK: — Shared Instance
    static let shared = MQTTManager()

    //    MARK: — Public Publisher
    /// Emits (topic, payload) tuples for any incoming messages.
    let messagePublisher = PassthroughSubject<(topic: String, payload: String), Never>()

    //    MARK: — Internal
    private var mqttClient: CocoaMQTT!

    /// 1) Replace with your broker’s hostname
    private let host = "gust.caps.ou.edu"
    /// 2) Use TLS port 8883 (standard for secure MQTT)
    private let port: UInt16 = 8883

    /// 3) Fill in the username/password you set up on the broker
    private let username: String? = "okeride_user"      // ← e.g. “okeride_user”
    private let password: String? = "someStrongPass"    // ← e.g. “vl%$kj3@!”

    //    MARK: — Init
    private override init() {
        super.init()

        // 4) Build a unique clientID; in your case you said “OKEride_VEHID”.
        //    We’ll let the app supply the VEHID at runtime via setClientID(_:)
        let defaultClientID = "OKEride_Client-Unset"
        mqttClient = CocoaMQTT(
            clientID: defaultClientID,
            host:     host,
            port:     port
        )

        // 5) Enable TLS (because port 8883 expects SSL)
        mqttClient.enableSSL = true
        // 6) Set credentials
        mqttClient.username = username
        mqttClient.password = password

        mqttClient.keepAlive = 60
        mqttClient.autoReconnect = true
        mqttClient.delegate = self
    }

    //    MARK: — Client-ID Setter
    /// Call this *before* connect() so that “OKEride_{VEHID}” is used.
    func setClientID(to vehID: String) {
        // For example “OKEride_ab12cd”
        mqttClient.clientID = "OKEride_\(vehID)"
    }

    //    MARK: — Connection
    func connect() {
        mqttClient.connect()
    }

    func disconnect() {
        mqttClient.disconnect()
    }

    //    MARK: — Subscriptions
    func subscribe(to topic: String) {
        mqttClient.subscribe(topic, qos: .qos1)
    }

    func unsubscribe(from topic: String) {
        mqttClient.unsubscribe(topic)
    }

    //    MARK: — Publishing
    /// Publish a raw string payload to any topic
    func publish(_ topic: String, message: String) {
        mqttClient.publish(topic, withString: message, qos: .qos1)
    }

    /// Helper to send an unlock command for a specific scooter.
    /// Rather than “scooter/{id}/command”,
    /// you want to publish to “okeride/{id}/src” with your JSON.
    func publishUnlockCommand(for scooterID: String) {
        let topic = "okeride/\(scooterID)/src"
        let payload = """
        {
          "action": "unlock"
        }
        """
        mqttClient.publish(topic, withString: payload, qos: .qos1)
    }
}

//    MARK: — CocoaMQTTDelegate
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
        // Forward every incoming message onto our Combine pipeline
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
        // Allow all TLS certs (for testing). In production, validate properly.
        completionHandler(true)
    }
}
