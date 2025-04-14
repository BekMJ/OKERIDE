import FirebaseFirestore

class ScooterViewModel: ObservableObject {
    @Published var scooters: [Scooter] = []
    private var db = Firestore.firestore()


    func fetchScooters() {
        db.collection("scooters").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents in scooters collection")
                return
            }
            self.scooters = documents.compactMap { doc -> Scooter? in
                let scooter = try? doc.data(as: Scooter.self)
                // LOG
                print("Fetched scooter doc: \(doc.documentID)")
                return scooter
            }
        }
    }

// For testing: load a fake scooter.
    /*
func loadFakeScooter() {
    // Create fake scooter data
    let fakeScooterData: [String: Any] = [
        "latitude": 35.23054891687646, "longitude": -97.47440413374802,
        "isAvailable": true,
        "name": "Test Scooter1"
    ]
    // Use a known document ID ("TEST123") so you can easily test the QR scanner flow.
    db.collection("scooters").document("TEST123").setData(fakeScooterData) { error in
        if let error = error {
            print("Error adding fake scooter: \(error.localizedDescription)")
        } else {
            print("Fake scooter added successfully!")
            // Optionally, you can then fetch the scooters:
            self.fetchScooters()
        }
    }
}*/

// Simulated unlocking: update the scooter's availability.
func unlockScooter(_ scooter: Scooter, completion: @escaping (Bool) -> Void) {
    guard let scooterID = scooter.id else {
        completion(false)
        return
    }
    db.collection("scooters").document(scooterID).updateData(["isAvailable": false]) { error in
        if let error = error {
            print("Error updating scooter: \(error.localizedDescription)")
            completion(false)
        } else {
            completion(true)
        }
    }
}
}
