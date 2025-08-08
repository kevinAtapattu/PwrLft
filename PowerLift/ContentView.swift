//
//  ContentView.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-07-31.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @StateObject private var vm = ViewModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let width: Double = 250
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress Ring and Time
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                    .frame(width: 220, height: 220)
                Circle()
                    .trim(from: 0, to: vm.progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                    .animation(.linear(duration: 0.5), value: vm.progress)
                Text(vm.time)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .padding(.top, 16)
            .alert("Time's Up", isPresented: $vm.showingAlert) {
                Button("OK", role: .cancel) {}
            }

            // Wheel Pickers like iOS Timer
            HStack(alignment: .center, spacing: 0) {
                VStack {
                    Picker("hours", selection: $vm.selectedHours) {
                        ForEach(0..<24) { Text("\($0)") }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .labelsHidden()
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #endif
                    Text("hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Picker("minutes", selection: $vm.selectedMinutes) {
                        ForEach(0..<60) { Text("\($0)") }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .labelsHidden()
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #endif
                    Text("min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Picker("seconds", selection: $vm.selectedSeconds) {
                        ForEach(0..<60) { Text("\($0)") }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .labelsHidden()
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #endif
                    Text("sec")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 160)
            .padding(.horizontal)

            // Recent durations
            if !vm.recentDurations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.recentDurations, id: \.self) { seconds in
                            Button(formatShort(seconds: seconds)) {
                                let h = seconds / 3600
                                let m = (seconds % 3600) / 60
                                let s = seconds % 60
                                vm.selectedHours = h
                                vm.selectedMinutes = m
                                vm.selectedSeconds = s
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Controls
            HStack(spacing: 24) {
                if vm.isActive && !vm.isPaused {
                    Button("Pause", action: vm.pause)
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                } else if vm.isActive && vm.isPaused {
                    Button("Resume", action: vm.resume)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                } else {
                    Button("Start", action: vm.start)
                        .buttonStyle(.borderedProminent)
                }

                Button("Cancel", action: vm.reset)
                    .buttonStyle(.bordered)
                    .tint(.red)
            }
            .padding(.bottom)
        }
        .onReceive(timer) { _ in
            vm.updateCountdown()
        }
    }
}



// Helper function to format seconds into short readable format
private func formatShort(seconds: Int) -> String {
    if seconds >= 3600 {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    } else if seconds >= 60 {
        let minutes = seconds / 60
        let secs = seconds % 60
        return "\(minutes)m \(secs)s"
    } else {
        return "\(seconds)s"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
