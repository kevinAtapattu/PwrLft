//
//  WorkoutLogViewModel.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-08-02.
//

import Foundation
import SwiftUI
import Supabase

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
    @State private var showingAddExercise = false

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
                // Header
                VStack(spacing: 8) {
                    Text("Workout Log")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Track your progress")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Workout Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Current Workout")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showingAddExercise.toggle() }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Exercise")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.blue)
                                    )
                                }
                            }
                            
                            if viewModel.currentWorkout.exercises.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "dumbbell")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("No exercises yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Text("Tap 'Add Exercise' to begin")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.currentWorkout.exercises) { exercise in
                                        ExerciseRow(exercise: exercise)
                                    }
                                }
                            }
                            
                            if !viewModel.currentWorkout.exercises.isEmpty {
                                Button(action: viewModel.completeWorkout) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Complete Workout")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Previous Workouts Section
                        if !viewModel.workouts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Previous Workouts")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: { showingAlert = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "trash")
                                            Text("Clear All")
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.red.opacity(0.2))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.workouts) { workout in
                                        WorkoutHistoryRow(workout: workout)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseSheet(viewModel: viewModel)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Clear All Workouts"),
                message: Text("Are you sure you want to delete all workout history? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete All")) {
                    viewModel.clearWorkouts()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(exercise.weight, specifier: "%.1f") lbs")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(workout.date, style: .date)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(workout.exercises.count) exercises")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(workout.exercises) { exercise in
                    HStack {
                        Text("• \(exercise.name)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(exercise.sets)×\(exercise.reps) @ \(exercise.weight, specifier: "%.1f") lbs")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AddExerciseSheet: View {
    @ObservedObject var viewModel: WorkoutLogViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        TextField("Exercise Name", text: $viewModel.newExerciseName)
                            .textFieldStyle(ModernTextFieldStyle())
                        
                        HStack(spacing: 16) {
                            TextField("Sets", text: $viewModel.newExerciseSets)
                                .textFieldStyle(ModernTextFieldStyle())
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            
                            TextField("Reps", text: $viewModel.newExerciseReps)
                                .textFieldStyle(ModernTextFieldStyle())
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                        }
                        
                        TextField("Weight (lbs)", text: $viewModel.newExerciseWeight)
                            .textFieldStyle(ModernTextFieldStyle())
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                    }
                    
                    Button(action: {
                        viewModel.addExercise()
                        dismiss()
                    }) {
                        Text("Add Exercise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                    }
                    .disabled(viewModel.newExerciseName.isEmpty || viewModel.newExerciseSets.isEmpty || viewModel.newExerciseReps.isEmpty || viewModel.newExerciseWeight.isEmpty)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
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
