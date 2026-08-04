//
//  ExerciseDatabase.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@MainActor
enum ExerciseDatabase {
    static var exercises: [ExerciseItem] {
        [
            // Planche
            ExerciseItem(name: "Tuck Planche", category: .planche, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Pseudo Planche Lean", category: .planche, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Knee Pseudo Planche Lean", category: .planche, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Bent-arm Planche", category: .planche, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Pseudo Planche Push-Ups", category: .planche, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),

            // Push
            ExerciseItem(name: "Dips", category: .push, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Russian Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Diamond Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 10, restSeconds: 60),
            ExerciseItem(name: "Bar One-Arm Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Archer Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Tricep Extensions", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Weighted Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 16, restSeconds: 60),

            // Pull
            ExerciseItem(name: "Assisted Muscle-Ups", category: .pull, numberOfSets: 3, numberOfReps: 1, restSeconds: 60),
            ExerciseItem(name: "Pull-Ups", category: .pull, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Pull-Up Negatives", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Assisted Pull-Ups", category: .pull, numberOfSets: 3, numberOfReps: 5, restSeconds: 60),
            ExerciseItem(name: "Inverted Rows", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Chin-Ups", category: .pull, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Chin-Up Negatives", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Assisted Chin-Ups", category: .pull, numberOfSets: 3, numberOfReps: 5, restSeconds: 60),
            ExerciseItem(name: "Tuck Front Lever", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Assisted Front Lever", category: .pull, numberOfSets: 3, numberOfReps: 10, restSeconds: 60),
            ExerciseItem(name: "Tuck Back Lever", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Dead Hangs", category: .pull, numberOfSets: 3, numberOfReps: 20, restSeconds: 60),

            // Legs
            ExerciseItem(name: "Dragon Squats", category: .legs, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Pistol Squats", category: .legs, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Bosu Squats", category: .legs, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Bulgarian Split Squats", category: .legs, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Squats", category: .legs, numberOfSets: 3, numberOfReps: 24, restSeconds: 90),
            ExerciseItem(name: "Lunges", category: .legs, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Reverse Lunges", category: .legs, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Calf Raises", category: .legs, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Glute Bridges", category: .legs, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),

            // Handstand
            ExerciseItem(name: "Handstand Push-Ups", categories: [.handstand, .push], numberOfSets: 5, numberOfReps: 1, restSeconds: 30),
            ExerciseItem(name: "Freestanding Handstand Holds", category: .handstand, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Wall Handstand Shoulder Taps", category: .handstand, numberOfSets: 3, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Wall Handstand Holds", category: .handstand, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Crow Pose", categories: [.handstand, .planche], numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Pike Push-Ups", categories: [.handstand, .push], numberOfSets: 3, numberOfReps: 8, restSeconds: 60),

            // L-sit
            ExerciseItem(name: "L-Sit Extensions", category: .lSit, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Tuck L-Sit", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "L-Sit Leg Raise Holds", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "L-Sit Leg Raises", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Hanging Leg Raise Holds", category: .lSit, numberOfSets: 3, numberOfReps: 6, restSeconds: 60),
            ExerciseItem(name: "Hanging Leg Raises", category: .lSit, numberOfSets: 3, numberOfReps: 10, restSeconds: 60),
            ExerciseItem(name: "L-Sit Support Holds", category: .lSit, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),

            // Core
            ExerciseItem(name: "Dragon Flag Negatives", category: .core, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Leg Raises", category: .core, numberOfSets: 3, numberOfReps: 12, restSeconds: 60),
            ExerciseItem(name: "Hollow Body Holds", category: .core, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Planks", category: .core, numberOfSets: 3, numberOfReps: 65, restSeconds: 90),
            ExerciseItem(name: "Side Planks", category: .core, numberOfSets: 3, numberOfReps: 60, restSeconds: 90),
            ExerciseItem(name: "Russian Twists", category: .core, numberOfSets: 3, numberOfReps: 20, restSeconds: 90)
        ]
    }

    // Increment this when the bundled exercise collection changes.
    private static let version = 1
    private static let installedVersionKey = "database.exerciseContentVersion"
    private static let legacyInstalledVersionKey =
        "database.defaultExerciseContentVersion"

    @discardableResult
    static func installIfNeeded(in modelContext: ModelContext) throws -> Bool {
        let preferences = UserDefaults.standard
        let currentInstalledVersion = preferences.integer(
            forKey: installedVersionKey
        )
        let legacyInstalledVersion = preferences.integer(
            forKey: legacyInstalledVersionKey
        )
        let installedVersion = max(
            currentInstalledVersion,
            legacyInstalledVersion
        )

        if currentInstalledVersion < installedVersion {
            preferences.set(installedVersion, forKey: installedVersionKey)
            preferences.removeObject(forKey: legacyInstalledVersionKey)
        }

        guard installedVersion < version else { return false }

        let savedExercises = try modelContext.fetch(FetchDescriptor<ExerciseItem>())
        let savedExercisesByName = Dictionary(
            grouping: savedExercises,
            by: { $0.name.normalizedForComparison }
        )
        let shouldInstallBundledExercises = installedVersion == 0
            && savedExercises.isEmpty

        for exercise in exercises {
            let normalizedName = exercise.name.normalizedForComparison

            if let matchingExercises = savedExercisesByName[normalizedName] {
                for savedExercise in matchingExercises {
                    overwrite(savedExercise, with: exercise)
                }
            } else if shouldInstallBundledExercises {
                modelContext.insert(exercise)
            }
        }

        try modelContext.save()
        preferences.set(version, forKey: installedVersionKey)
        preferences.removeObject(forKey: legacyInstalledVersionKey)
        return true
    }

    private static func overwrite(
        _ savedExercise: ExerciseItem,
        with databaseExercise: ExerciseItem
    ) {
        savedExercise.name = databaseExercise.name
        savedExercise.exerciseCategories = databaseExercise.exerciseCategories
        savedExercise.numberOfSets = databaseExercise.numberOfSets
        savedExercise.numberOfReps = databaseExercise.numberOfReps
        savedExercise.restSeconds = databaseExercise.restSeconds
    }
}
