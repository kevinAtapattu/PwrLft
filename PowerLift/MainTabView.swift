//
//  MainTabView.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-08-01.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Rest", systemImage: "timer")
                }
            Text("Other Tab")
                .tabItem{
                    Label("Other", systemImage: "ellipsis")
                }
        }
    }
        
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View{
        MainTabView()
    }
}
