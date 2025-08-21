import SwiftUI
import Supabase

@main
struct PowerLiftApp: App {
    let client = SupabaseClient(
      supabaseURL: URL(string: "https://xexggquvtjrfmxmdaeaz.supabase.co")!,
      supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhleGdncXV2dGpyZm14bWRhZWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjMyMjgwNjAsImV4cCI6MjAzODgwNDA2MH0.VkQ8GOikSniDjBXW4WI3kaZPo-TR_YpGWyGA6aSyRcQ"
    )
    
    var body: some Scene {
        WindowGroup {
            MainTabView(client: client)
                .preferredColorScheme(.dark)
                .accentColor(.blue)
        }
    }
}
