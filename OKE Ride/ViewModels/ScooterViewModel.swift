import FirebaseFirestore
import Combine

class ScooterViewModel: ObservableObject {
    @Published var scooters: [Scooter] = []
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 1) Load initial scooter list from Firestore
        fetchScootersFromFirestore()
        // 2) Start listening for live status updates via MQTT
        setupMQTTListener()
    }
    
    // MARK: — Firestore loading (unchanged)
    func fetchScootersFromFirestore() {
        db.collection("scooters").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.scooters = docs.compactMap { try? $0.data(as: Scooter.self) }
        }
    }

    // MARK: — MQTT subscription
    private func setupMQTTListener() {
        MQTTManager.shared
            .messagePublisher
            .sink { [weak self] topic, payload in
                // Expect topic = "scooter/{id}/status"
                let parts = topic.split(separator: "/")
                guard parts.count == 3,
                      parts[0] == "scooter",
                      parts[2] == "status"
                else { return }
                let scooterID = String(parts[1])
                
                // Decode JSON payload into a status model
                struct Status: Decodable {
                    let batteryLevel: Int
                    let latitude:    Double
                    let longitude:   Double
                    let isAvailable: Bool
                }
                
                guard
                  let data = payload.data(using: .utf8),
                  let status = try? JSONDecoder().decode(Status.self, from: data)
                else { return }

                DispatchQueue.main.async {
                    if let idx = self?.scooters.firstIndex(where: { $0.id == scooterID }) {
                        // Update existing scooter
                        self?.scooters[idx].batteryLevel = status.batteryLevel
                        self?.scooters[idx].latitude     = status.latitude
                        self?.scooters[idx].longitude    = status.longitude
                        self?.scooters[idx].isAvailable  = status.isAvailable
                    } else {
                        // Or append brand new scooter
                        let newScooter = Scooter(
                          id:           scooterID,
                          latitude:     status.latitude,
                          longitude:    status.longitude,
                          isAvailable:  status.isAvailable,
                          name:         "Unknown",
                          batteryLevel: status.batteryLevel
                        )

                        self?.scooters.append(newScooter)
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: — MQTT unlock command
    func unlockScooterViaMQTT(_ scooter: Scooter) {
        guard let id = scooter.id else { return }
        MQTTManager.shared.publishUnlockCommand(for: id)
    }
}
