//
//  ContentView.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-07-31.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ViewModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let width: Double = 250
    
    var body: some View {
        VStack {
            Text("\(vm.time)")
                .font(.system(size: 70, weight: .medium, design: .rounded))
                .padding()
                .frame(width: width)
                .background(.thinMaterial)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 4))
                .alert("Timer Done!", isPresented: $vm.showingAlert) {
                    Button("Continue", role: .cancel){
                        
                    }
                }
            
            Slider(value: $vm.minutes, in: 1...10, step: 1)
                .padding()
                .frame(width: width)
                .animation(.easeInOut, value: vm.minutes)
            
            HStack(spacing: 50) {
                Button("Start") {
                    vm.start(minutes: vm.minutes)
                }
                .disabled(vm.isActive)
                
                Button("Reset", action: vm.reset)
                    .tint(.red)
            }
            .frame(width: width)
            
            }
        .onReceive(timer) { _ in
        vm.updateCountdown()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
