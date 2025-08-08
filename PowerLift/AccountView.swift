import Foundation
import SwiftUI
import Supabase

struct AccountView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    let client: SupabaseClient // Add this line to store the SupabaseClient instance
    
    var body: some View {
        VStack {
            if isLoggedIn {
                Text("Account")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    // Log out the user
                    isLoggedIn = false
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            } else {
                // Show login/signup screen
                LoginSignupView(client: client) // Pass the SupabaseClient instance
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let client = SupabaseClient(supabaseURL: URL(string: "https://your-project-id.supabase.co")!, supabaseKey: "your-anon-key")
        AccountView(client: client) // Provide the client here as well
    }
}
