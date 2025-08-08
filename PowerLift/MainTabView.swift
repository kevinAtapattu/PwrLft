import Foundation
import SwiftUI
import Supabase

struct MainTabView: View {
    let client: SupabaseClient // Add this line to store the SupabaseClient instance
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Rest", systemImage: "timer")
                }
            WorkoutLogView()
                .tabItem {
                    Label("Log Workout", systemImage: "chart.bar.xaxis.ascending")
                }
            OneRMCalculatorView()
                .tabItem {
                    Label("One-RM", systemImage: "figure.strengthtraining.traditional")
                }
            AccountView(client: client) // Pass the client to AccountView
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let client = SupabaseClient(supabaseURL: URL(string: "https://xexggquvtjrfmxmdaeaz.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhleGdncXV2dGpyZm14bWRhZWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjMyMjgwNjAsImV4cCI6MjAzODgwNDA2MH0.VkQ8GOikSniDjBXW4WI3kaZPo-TR_YpGWyGA6aSyRcQ")
        MainTabView(client: client) // Provide the client here as well
    }
}
