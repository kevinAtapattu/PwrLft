import Foundation
import SwiftUI
import Supabase

struct LoginSignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = "" // Optional username
    let client: SupabaseClient // Inject the client as a regular object

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Username (optional)", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Sign Up") {
                Task {
                    await signUpUser()
                }
            }
            .padding()

            Button("Sign In") {
                Task {
                    await signInUser()
                }
            }
            .padding()
        }
        .padding()
    }

    private func signUpUser() async {
        do {
            let session = try await client.auth.signUp(email: email, password: password)
            print("User signed up: \(session)")
            
            // Convert UUID to String
            let userId = session.user.id.uuidString
            await saveUserToDatabase(userId: userId)
            
        } catch {
            print("Sign up failed: \(error.localizedDescription)")
        }
    }

    private func signInUser() async {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            print("User signed in: \(session)")
            
            // Convert UUID to String
            let userId = session.user.id.uuidString
            await fetchUserData(userId: userId)
            
        } catch {
            print("Sign in failed: \(error.localizedDescription)")
        }
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

        // Create an instance of the User struct
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
                // Handle user data (e.g., store in app state or display in UI)
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
