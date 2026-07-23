//
//  DefaultExerciseDatabase.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@MainActor
enum DefaultExerciseDatabase {
    static var exercises: [ExerciseItem] {
        [
            // Planche
            ExerciseItem(name: "Tuck Planche", category: .planche, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Pseudo Planche Lean", category: .planche, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Knee Pseudo Planche Lean", category: .planche, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Pseudo Planche Push-Ups", category: .planche, numberOfSets: 3, numberOfReps: 6, restSeconds: 60),

            // Push
            ExerciseItem(name: "Dips", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Russian Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 7, restSeconds: 90),
            ExerciseItem(name: "Diamond Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 7, restSeconds: 60),
            ExerciseItem(name: "Tricep Extensions", category: .push, numberOfSets: 3, numberOfReps: 7, restSeconds: 60),
            ExerciseItem(name: "Push-Ups", category: .push, numberOfSets: 3, numberOfReps: 15, restSeconds: 60),

            // Pull
            ExerciseItem(name: "Assisted Muscle-Ups", category: .pull, numberOfSets: 3, numberOfReps: 1, restSeconds: 60),
            ExerciseItem(name: "Pull-Ups", category: .pull, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Pull-Up Negatives", category: .pull, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Assisted Pull-Ups", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Chin-Ups", category: .pull, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Chin-Up Negatives", category: .pull, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Assisted Chin-Ups", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Tuck Front Lever", category: .pull, numberOfSets: 3, numberOfReps: 5, restSeconds: 60),
            ExerciseItem(name: "Assisted Front Lever", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Dead Hangs", category: .pull, numberOfSets: 3, numberOfReps: 15, restSeconds: 60),

            // Legs
            ExerciseItem(name: "Pistol Squats", category: .legs, numberOfSets: 3, numberOfReps: 7, restSeconds: 90),
            ExerciseItem(name: "Squats", category: .legs, numberOfSets: 3, numberOfReps: 24, restSeconds: 90),
            ExerciseItem(name: "Lunges", category: .legs, numberOfSets: 3, numberOfReps: 16, restSeconds: 90),
            ExerciseItem(name: "Calf Raises", category: .legs, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),

            // Handstand
            ExerciseItem(name: "Handstand Push-Ups", category: .handstand, numberOfSets: 5, numberOfReps: 1, restSeconds: 30),
            ExerciseItem(name: "Freestanding Handstand Holds", category: .handstand, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Wall Handstand Shoulder Taps", category: .handstand, numberOfSets: 3, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Wall Handstand Holds", category: .handstand, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Crow Pose", category: .handstand, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Pike Push-Ups", category: .handstand, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),

            // Core
            ExerciseItem(name: "L-Sit Extensions", category: .core, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Tuck L-Sit", category: .core, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "L-Sit Leg Raises", category: .core, numberOfSets: 3, numberOfReps: 6, restSeconds: 60),
            ExerciseItem(name: "Hanging Leg Raises", category: .core, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Leg Raises", category: .core, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Hollow Body Holds", category: .core, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Planks", category: .core, numberOfSets: 3, numberOfReps: 60, restSeconds: 90)
        ]
    }

    // Increment this when the default exercise collection changes.
    private static let version = 3
    private static let installedVersionKey = "database.defaultExerciseContentVersion"

    static func installIfNeeded(in modelContext: ModelContext) throws {
        let installedVersion = UserDefaults.standard.integer(
            forKey: installedVersionKey
        )
        guard installedVersion < version else { return }

        let savedExercises = try modelContext.fetch(FetchDescriptor<ExerciseItem>())
        var savedNames = Set(savedExercises.map { $0.name.normalizedForComparison })

        for exercise in exercises {
            guard savedNames.insert(exercise.name.normalizedForComparison).inserted else {
                continue
            }
            modelContext.insert(exercise)
        }

        try modelContext.save()
        UserDefaults.standard.set(version, forKey: installedVersionKey)
    }

}
