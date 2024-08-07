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
            WorkoutLogView()
                .tabItem {
                    Label("Log Workout", systemImage: "chart.bar.xaxis.ascending")
                }
            OneRMCalculatorView()
                .tabItem {
                    Label("One-RM", systemImage: "figure.strengthtraining.traditional")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View{
        MainTabView()
    }
}
