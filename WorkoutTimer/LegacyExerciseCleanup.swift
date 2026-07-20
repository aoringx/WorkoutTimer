//
//  LegacyExerciseCleanup.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

enum LegacyExerciseCleanup {
    static let didCleanupKey = "migration.didRemoveExperimentalExercises"

    private static let legacySeedKey = "development.didSeedExperimentalExercises"

    private struct SeededExercise {
        let name: String
        let category: ExerciseCategory
        let notes: String
        let sets: Int
        let reps: Int
        let restSeconds: Int

        func matches(_ exercise: ExerciseItem) -> Bool {
            exercise.name == name
                && exercise.exerciseCategory == category
                && exercise.notes == notes
                && exercise.numberOfSets == sets
                && exercise.numberOfReps == reps
                && exercise.restSeconds == restSeconds
        }
    }

    private static let seededExercises = [
        SeededExercise(
            name: "Wall Walk",
            category: .handstand,
            notes: "Walk the feet up the wall while keeping the core tight.",
            sets: 3,
            reps: 5,
            restSeconds: 60
        ),
        SeededExercise(
            name: "Push-Up",
            category: .push,
            notes: "Keep a straight body line and lower with control.",
            sets: 3,
            reps: 10,
            restSeconds: 60
        ),
        SeededExercise(
            name: "Pull-Up",
            category: .pull,
            notes: "Start from a full hang and pull the chest toward the bar.",
            sets: 3,
            reps: 5,
            restSeconds: 90
        ),
        SeededExercise(
            name: "Bodyweight Squat",
            category: .legs,
            notes: "Keep the heels planted and knees tracking over the toes.",
            sets: 3,
            reps: 12,
            restSeconds: 60
        ),
        SeededExercise(
            name: "Hanging Knee Raise",
            category: .core,
            notes: "Avoid swinging and raise the knees with the abdominals.",
            sets: 3,
            reps: 10,
            restSeconds: 60
        ),
        SeededExercise(
            name: "Planche Lean",
            category: .planche,
            notes: "Keep the elbows locked and lean forward gradually.",
            sets: 3,
            reps: 8,
            restSeconds: 90
        )
    ]

    static func removeSeededExercises(in modelContext: ModelContext) throws {
        guard UserDefaults.standard.bool(forKey: legacySeedKey) else { return }

        let savedExercises = try modelContext.fetch(FetchDescriptor<ExerciseItem>())
        for exercise in savedExercises
        where seededExercises.contains(where: { $0.matches(exercise) }) {
            modelContext.delete(exercise)
        }

        try modelContext.save()
        UserDefaults.standard.removeObject(forKey: legacySeedKey)
    }
}
