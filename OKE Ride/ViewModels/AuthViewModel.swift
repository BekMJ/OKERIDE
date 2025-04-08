import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String, rememberPassword: Bool, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                self.user = result?.user
                onSuccess()
            }
        }
    }
    
    func register(email: String, password: String, rememberPassword: Bool, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                self.user = result?.user
                onSuccess()
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
