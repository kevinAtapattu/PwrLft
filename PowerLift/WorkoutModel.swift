//
//  WorkoutModel.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-08-02.
//

import Foundation

struct Workout: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var exercises: [Exercise]
}

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var reps: Int
    var sets: Int
    var weight: Double
}
