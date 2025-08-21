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
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // Changed from 1.0 to 0.1 for smooth progress
    
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
                ScrollView {
                    VStack(spacing: 32) {
                        // Header with safe area padding
                        VStack(spacing: 8) {
                            Text("Rest Timer")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Set your rest interval")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60) // Increased top padding to avoid notch
                        
                        // Progress Ring and Time - Now tappable
                        ZStack {
                            // Outer glow
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                .frame(width: 280, height: 280)
                                .blur(radius: 8)
                            
                            // Background circle
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 240, height: 240)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: vm.progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 240, height: 240)
                                .animation(.linear(duration: 0.5), value: vm.progress)
                            
                            // Time display
                            VStack(spacing: 4) {
                                Text(vm.time)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundColor(.white)
                                
                                if vm.isActive {
                                    Text(vm.isPaused ? "Paused" : "Running")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(vm.isPaused ? .orange : .green)
                                } else {
                                    Text("Tap to start")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .onTapGesture {
                            // Handle tap on timer circle
                            if vm.isActive {
                                if vm.isPaused {
                                    vm.resume()
                                } else {
                                    vm.pause()
                                }
                            } else {
                                vm.start()
                            }
                        }
                        .scaleEffect(vm.isActive ? 1.0 : 0.98)
                        .animation(.easeInOut(duration: 0.2), value: vm.isActive)
                        
                        // Stop/Reset Button - Moved above duration pickers
                        if vm.isActive {
                            Button(action: vm.reset) {
                                HStack(spacing: 8) {
                                    Image(systemName: "stop.fill")
                                    Text("Stop Timer")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 160, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.red.opacity(0.8))
                                )
                            }
                            .padding(.bottom, 20)
                        }
                        
                        // Duration Pickers
                        VStack(spacing: 16) {
                            Text("Set Duration")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack(alignment: .center, spacing: 0) {
                                // Hours picker
                                VStack(spacing: 8) {
                                    Picker("hours", selection: $vm.selectedHours) {
                                        ForEach(0..<24) { hour in
                                            Text("\(hour)")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .labelsHidden()
                                    #if os(iOS)
                                    .pickerStyle(.wheel)
                                    #endif
                                    
                                    Text("hours")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                
                                // Minutes picker
                                VStack(spacing: 8) {
                                    Picker("minutes", selection: $vm.selectedMinutes) {
                                        ForEach(0..<60) { minute in
                                            Text("\(minute)")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .labelsHidden()
                                    #if os(iOS)
                                    .pickerStyle(.wheel)
                                    #endif
                                    
                                    Text("min")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                
                                // Seconds picker
                                VStack(spacing: 8) {
                                    Picker("seconds", selection: $vm.selectedSeconds) {
                                        ForEach(0..<60) { second in
                                            Text("\(second)")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .labelsHidden()
                                    #if os(iOS)
                                    .pickerStyle(.wheel)
                                    #endif
                                    
                                    Text("sec")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(height: 140)
                            .padding(.horizontal)
                        }
                        
                        // Recent durations - Reduced gap from duration pickers
                        if !vm.recentDurations.isEmpty {
                            VStack(spacing: 12) {
                                Text("Recent")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(vm.recentDurations, id: \.self) { seconds in
                                            Button(action: {
                                                let h = seconds / 3600
                                                let m = (seconds % 3600) / 60
                                                let s = seconds % 60
                                                vm.selectedHours = h
                                                vm.selectedMinutes = m
                                                vm.selectedSeconds = s
                                            }) {
                                                Text(formatShort(seconds: seconds))
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(Color.blue.opacity(0.3))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 8) // Small gap from duration pickers
                            .padding(.bottom, 30)
                        }
                    }
                    .padding(.horizontal, 20) // Add horizontal padding for better edge spacing
                }
            }
        }
        .onReceive(timer) { _ in
            vm.updateCountdown()
        }
        .alert("Time's Up!", isPresented: $vm.showingAlert) {
            Button("OK", role: .cancel) {}
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
