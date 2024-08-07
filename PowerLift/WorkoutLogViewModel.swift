//
//  WorkoutLogViewModel.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-08-02.
//

import Foundation
import SwiftUI

class WorkoutLogViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var currentWorkout: Workout = Workout(date: Date(), exercises: [])
    @Published var newExerciseName: String = ""
    @Published var newExerciseReps: String = ""
    @Published var newExerciseSets: String = ""
    @Published var newExerciseWeight: String = ""

    init() {
        loadWorkouts()
    }

    func addExercise() {
        guard let reps = Int(newExerciseReps), let sets = Int(newExerciseSets), let weight = Double(newExerciseWeight) else { return }
        let exercise = Exercise(name: newExerciseName, reps: reps, sets: sets, weight: weight)
        currentWorkout.exercises.append(exercise)
        newExerciseName = ""
        newExerciseReps = ""
        newExerciseSets = ""
        newExerciseWeight = ""
    }

    func completeWorkout() {
        workouts.append(currentWorkout)
        saveWorkouts()
        currentWorkout = Workout(date: Date(), exercises: [])
    }

    func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: "workouts") {
            if let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
                workouts = decoded
            }
        }
    }

    func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
    }
    
    func clearWorkouts() {
            workouts.removeAll()
            UserDefaults.standard.removeObject(forKey: "workouts")
        }
}


struct WorkoutLogView: View {
    @StateObject private var viewModel = WorkoutLogViewModel()
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Current Workout")) {
                        ForEach(viewModel.currentWorkout.exercises) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                Text("Reps: \(exercise.reps), Sets: \(exercise.sets), Weight: \(exercise.weight, specifier: "%.2f") lbs")
                            }
                        }
                        HStack {
                            TextField("Exercise", text: $viewModel.newExerciseName)
                            TextField("Reps", text: $viewModel.newExerciseReps)
                                .keyboardType(.numberPad)
                            TextField("Sets", text: $viewModel.newExerciseSets)
                                .keyboardType(.numberPad)
                            TextField("Weight", text: $viewModel.newExerciseWeight)
                                .keyboardType(.decimalPad)
                            Button(action: viewModel.addExercise) {
                                Text("Add")
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("Workout Log")

                Button(action: viewModel.completeWorkout) {
                    Text("Complete Workout")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                List {
                    Section(header: Text("Previous Workouts")) {
                        ForEach(viewModel.workouts) { workout in
                            VStack(alignment: .leading) {
                                Text(workout.date, style: .date)
                                ForEach(workout.exercises) { exercise in
                                    Text("\(exercise.name): \(exercise.reps) reps x \(exercise.sets) sets, \(exercise.weight, specifier: "%.2f") lbs")
                                }
                            }
                        }
                    }
                }

                Button(action: { showingAlert = true }) {
                    Text("Clear Workouts")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Clear Workouts"),
                        message: Text("Are you sure you want to delete all workouts?"),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.clearWorkouts()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
}

struct WorkoutLogView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutLogView()
    }
}
