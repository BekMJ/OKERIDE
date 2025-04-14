import SwiftUI
import FirebaseAuth

struct SignInView: View {
    enum AuthMode {
        case login, register
    }
    
    @State private var authMode: AuthMode = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("rememberPassword") private var rememberPassword: Bool = false
    @AppStorage("savedEmail") private var savedEmail: String = ""
    @AppStorage("savedPassword") private var savedPassword: String = ""

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            if let user = authViewModel.user {
                // Home screen after successful login
                HomeView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                // Sign In/Register screen
                VStack(spacing: 24) {
                    // Logo
                    Image("Image") // Your logo image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.top, 40)
                    
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Auth mode picker (Login/Register)
                    Picker(selection: $authMode, label: Text("Authentication Mode")) {
                        Text("Login").tag(AuthMode.login)
                        Text("Register").tag(AuthMode.register)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    
                    // Card for email/password input
                    VStack(spacing: 16) {
                        // Email field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        
                        // Password field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("Password", text: $password)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        
                        // Remember password toggle
                        Toggle("Remember Password", isOn: $rememberPassword)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                        
                        // Display error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        // Login/Register button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if authMode == .login {
                                    login()
                                } else {
                                    register()
                                }
                            }
                        }) {
                            Text(authMode == .login ? "Login" : "Register")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(authMode == .login ? Color.blue : Color.green)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    // Forgot password button
                    Button("Forgot Password?") {
                        // Implement forgot password flow here
                    }
                    .foregroundColor(Color.white.opacity(0.8))
                    .font(.footnote)
                }
                .onAppear {
                    // Auto-fill credentials if "Remember Password" is on
                    if rememberPassword {
                        email = savedEmail
                        password = savedPassword
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.user)
    }
    
    // MARK: - Firebase Authentication Methods
    
    func login() {
        authViewModel.signIn(email: email, password: password, rememberPassword: rememberPassword, onSuccess: {
            if rememberPassword {
                savedEmail = email
                savedPassword = password
            }
        }, onFailure: { error in
            errorMessage = error
        })
    }
    
    func register() {
        authViewModel.register(email: email, password: password, rememberPassword: rememberPassword, onSuccess: {
            if rememberPassword {
                savedEmail = email
                savedPassword = password
            }
        }, onFailure: { error in
            errorMessage = error
        })
    }
}
