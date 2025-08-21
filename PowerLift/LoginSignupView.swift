import Foundation
import SwiftUI
import Supabase

struct LoginSignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var isSignUp: Bool = false
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    let client: SupabaseClient

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        // App Logo/Icon
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 8) {
                            Text("iLift")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(isSignUp ? "Create your account" : "Welcome back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        if isSignUp {
                            ModernInputField(
                                title: "Username",
                                placeholder: "Enter your username",
                                text: $username,
                                icon: "person.fill"
                            )
                        }
                        
                        ModernInputField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email,
                            icon: "envelope.fill"
                        )
                        
                        ModernInputField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Button
                    Button(action: {
                        Task {
                            await performAuth()
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: isSignUp ? "person.badge.plus" : "arrow.right.circle.fill")
                            }
                            
                            Text(isSignUp ? "Create Account" : "Sign In")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                    }
                    .disabled(email.isEmpty || password.isEmpty || (isSignUp && username.isEmpty) || isLoading)
                    .padding(.horizontal, 20)
                    
                    // Toggle Mode
                    Button(action: { isSignUp.toggle() }) {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .alert("Authentication", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func performAuth() async {
        isLoading = true
        
        do {
            if isSignUp {
                let session = try await client.auth.signUp(email: email, password: password)
                print("User signed up: \(session)")
                
                let userId = session.user.id.uuidString
                await saveUserToDatabase(userId: userId)
                
                alertMessage = "Account created successfully! Please check your email to verify your account."
            } else {
                let session = try await client.auth.signIn(email: email, password: password)
                print("User signed in: \(session)")
                
                let userId = session.user.id.uuidString
                await fetchUserData(userId: userId)
                
                alertMessage = "Welcome back!"
            }
            
            showAlert = true
        } catch {
            alertMessage = "Authentication failed: \(error.localizedDescription)"
            showAlert = true
        }
        
        isLoading = false
    }

    // Define a struct that conforms to Encodable
    struct User: Encodable {
        let id: String
        let email: String
        let username: String?
        let created_at: String
    }

    private func saveUserToDatabase(userId: String) async {
        let dateFormatter = ISO8601DateFormatter()
        let formattedDate = dateFormatter.string(from: Date())

        let newUser = User(id: userId, email: email, username: username.isEmpty ? nil : username, created_at: formattedDate)

        do {
            let _ = try await client.from("users").insert(newUser).execute()
            print("User data saved to database.")
        } catch {
            print("Failed to save user data: \(error.localizedDescription)")
        }
    }

    private func fetchUserData(userId: String) async {
        do {
            let response = try await client.from("users").select().eq("id", value: userId).execute()
            if let userData = response.data.first {
                print("User data fetched: \(userData)")
            }
        } catch {
            print("Failed to fetch user data: \(error.localizedDescription)")
        }
    }
}

struct LoginSignupView_Previews: PreviewProvider {
    static var previews: some View {
        let client = SupabaseClient(supabaseURL: URL(string: "https://your-project-id.supabase.co")!, supabaseKey: "your-anon-key")
        LoginSignupView(client: client)
    }
}
