//
//  OneRMCalculatorView.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-08-02.
//

import Foundation
import SwiftUI

struct OneRMCalculatorView: View {
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var bodyweight: String = ""
    @State private var oneRM: Double = 0.0
    @State private var bodyweightAdjustedRM: Double = 0.0
    @State private var selectedFormula: RMFormula = .brzycki
    
    enum RMFormula: String, CaseIterable {
        case brzycki = "Brzycki"
        case epley = "Epley"
        case lombardi = "Lombardi"
        case oConner = "O'Conner"
        
        func calculate(weight: Double, reps: Double) -> Double {
            switch self {
            case .brzycki:
                return weight * (36 / (37 - reps))
            case .epley:
                return weight * (1 + reps / 30)
            case .lombardi:
                return weight * pow(reps, 0.1)
            case .oConner:
                return weight * (1 + reps / 40)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("1RM Calculator")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Estimate your one-rep maximum")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Formula Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Calculation Method")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(RMFormula.allCases, id: \.self) { formula in
                                Button(action: { selectedFormula = formula }) {
                                    HStack {
                                        Text(formula.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedFormula == formula ? .white : .gray)
                                        
                                        Spacer()
                                        
                                        if selectedFormula == formula {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedFormula == formula ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedFormula == formula ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        ModernInputField(
                            title: "Weight Lifted",
                            placeholder: "Enter weight in lbs",
                            text: $weight,
                            icon: "dumbbell.fill",
                            isSecure: false
                        )
                        
                        ModernInputField(
                            title: "Number of Reps",
                            placeholder: "Enter reps performed",
                            text: $reps,
                            icon: "repeat.circle.fill",
                            isSecure: false
                        )
                        
                        ModernInputField(
                            title: "Body Weight (Optional)",
                            placeholder: "Enter your body weight",
                            text: $bodyweight,
                            icon: "person.fill",
                            isSecure: false
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Calculate Button
                    Button(action: calculateOneRM) {
                        HStack(spacing: 8) {
                            Image(systemName: "function")
                            Text("Calculate 1RM")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                    }
                    .disabled(weight.isEmpty || reps.isEmpty)
                    .padding(.horizontal, 20)
                    
                    // Results
                    if oneRM > 0 {
                        VStack(spacing: 20) {
                            // Main 1RM Result
                            VStack(spacing: 12) {
                                Text("Estimated 1RM")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Text("\(oneRM, specifier: "%.1f") lbs")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            
                            // Bodyweight Adjusted Result
                            if !bodyweight.isEmpty && Double(bodyweight) ?? 0 > 0 {
                                VStack(spacing: 12) {
                                    Text("Strength-to-Weight Ratio")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("\(bodyweightAdjustedRM, specifier: "%.1f") lbs")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.cyan)
                                        .monospacedDigit()
                                    
                                    Text("\(oneRM / (Double(bodyweight) ?? 1), specifier: "%.2f")x bodyweight")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.cyan.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
    }

    func calculateOneRM() {
        let w = Double(weight) ?? 0
        let r = Double(reps) ?? 0
        let bw = Double(bodyweight) ?? 0
        
        oneRM = selectedFormula.calculate(weight: w, reps: r)
        
        if bw > 0 {
            bodyweightAdjustedRM = oneRM + (0.0333 * oneRM * (bw / 100))
        } else {
            bodyweightAdjustedRM = oneRM
        }
    }
}

struct OneRMCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        OneRMCalculatorView()
    }
}
