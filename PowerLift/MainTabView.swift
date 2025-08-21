import Foundation
import SwiftUI
import Supabase

struct MainTabView: View {
    let client: SupabaseClient
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            WorkoutLogView()
                .tabItem {
                    Label("Workouts", systemImage: "dumbbell.fill")
                }
            
            OneRMCalculatorView()
                .tabItem {
                    Label("1RM", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            AccountView(client: client)
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .accentColor(.blue)
        #if os(iOS)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        #endif
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let client = SupabaseClient(supabaseURL: URL(string: "https://xexggquvtjrfmxmdaeaz.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhleGdncXV2dGpyZm14bWRhZWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjMyMjgwNjAsImV4cCI6MjAzODgwNDA2MH0.VkQ8GOikSniDjBXW4WI3kaZPo-TR_YpGWyGA6aSyRcQ")
        MainTabView(client: client)
    }
}
