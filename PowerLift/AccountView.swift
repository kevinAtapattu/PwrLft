import Foundation
import SwiftUI
import Supabase

struct AccountView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
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
            
            VStack(spacing: 0) {
                if isLoggedIn {
                    // Profile Header
                    VStack(spacing: 24) {
                        // Profile Picture Placeholder
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Welcome Back!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Your fitness journey continues")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    // Account Options
                    VStack(spacing: 16) {
                        AccountOptionRow(
                            icon: "person.circle.fill",
                            title: "Edit Profile",
                            subtitle: "Update your information",
                            action: { /* TODO: Implement profile editing */ }
                        )
                        
                        AccountOptionRow(
                            icon: "gear",
                            title: "Settings",
                            subtitle: "App preferences and options",
                            action: { /* TODO: Implement settings */ }
                        )
                        
                        AccountOptionRow(
                            icon: "chart.bar.fill",
                            title: "Progress Stats",
                            subtitle: "View your fitness analytics",
                            action: { /* TODO: Implement progress stats */ }
                        )
                        
                        AccountOptionRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            subtitle: "Get assistance and tips",
                            action: { /* TODO: Implement help */ }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Sign Out Button
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.8))
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                } else {
                    // Show login/signup screen
                    LoginSignupView(client: client)
                }
            }
        }
    }
}

struct AccountOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let client = SupabaseClient(supabaseURL: URL(string: "https://your-project-id.supabase.co")!, supabaseKey: "your-anon-key")
        AccountView(client: client)
    }
}
