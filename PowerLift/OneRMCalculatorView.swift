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
    
    var body: some View {
        VStack {
            Text("1RM Calculator")
                .font(.largeTitle)
                .padding()
            TextField("Enter weight lifted", text: $weight)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter number of reps", text: $reps)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter your bodyweight", text: $bodyweight)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: calculateOneRM) {
                Text("Calculate")
            }
            .padding()
            Text("Estimated 1RM: \(bodyweightAdjustedRM, specifier: "%.2f") lbs")
                .padding()
        }
        .padding()
    }

    func calculateOneRM() {
        let w = Double(weight) ?? 0
        let r = Double(reps) ?? 0
        let bw = Double(bodyweight) ?? 0
        oneRM = w * (1 + (r / 30))
        bodyweightAdjustedRM = oneRM + (0.0333 * oneRM * (bw / 100))
    }
}

struct OneRMCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        OneRMCalculatorView()
    }
}
