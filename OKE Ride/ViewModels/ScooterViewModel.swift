import Foundation
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
                try? doc.data(as: Scooter.self)
            }
        }
    }
    
    func unlockScooter(_ scooter: Scooter, completion: @escaping (Bool) -> Void) {
        guard let docID = scooter.id else {
            completion(false)
            return
        }
        db.collection("scooters").document(docID).updateData(["isAvailable": false]) { error in
            if let error = error {
                print("Error updating scooter: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
