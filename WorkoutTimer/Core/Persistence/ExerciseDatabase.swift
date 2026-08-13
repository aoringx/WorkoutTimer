//
//  ExerciseDatabase.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@MainActor
enum ExerciseDatabase {
    private struct ExerciseDefinition {
        let name: String
        let category: ExerciseCategory
        let numberOfReps: Int
        let numberOfSets: Int
        let restSeconds: Int
    }

    private static let definitions = [
        // Planche
        ExerciseDefinition(name: "Tuck Planche", category: .planche, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pseudo Planche Lean", category: .planche, numberOfReps: 15, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Knee Pseudo Planche Lean", category: .planche, numberOfReps: 15, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Bent-arm Planche", category: .planche, numberOfReps: 12, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pseudo Planche Push-ups", category: .planche, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Crow Pose", category: .planche, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),

        // Push
        ExerciseDefinition(name: "Handstand Push-ups", category: .push, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pike Push-ups", category: .push, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Dips", category: .push, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Russian Push-ups", category: .push, numberOfReps: 6, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Diamond Push-ups", category: .push, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Bar One-arm Push-ups", category: .push, numberOfReps: 6, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Archer Push-ups", category: .push, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Tricep Extensions", category: .push, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Explosive Pushups", category: .push, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Finger Push-ups", category: .push, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Push-ups", category: .push, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),

        // Pull
        ExerciseDefinition(name: "Assisted Muscle-ups", category: .pull, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pull-ups", category: .pull, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pull-up Negatives", category: .pull, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Assisted Pull-ups", category: .pull, numberOfReps: 5, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Inverted Rows", category: .pull, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Chin-ups", category: .pull, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Chin-up Negatives", category: .pull, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Assisted Chin-ups", category: .pull, numberOfReps: 5, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Tuck Front Lever", category: .pull, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Assisted Front Lever", category: .pull, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Tuck Back Lever", category: .pull, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Active Hangs", category: .pull, numberOfReps: 15, numberOfSets: 2, restSeconds: 60),
        ExerciseDefinition(name: "Dead Hangs", category: .pull, numberOfReps: 15, numberOfSets: 2, restSeconds: 60),

        // Legs
        ExerciseDefinition(name: "Dragon Squats", category: .legs, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Bosu Pistol Squats", category: .legs, numberOfReps: 4, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pistol Squats", category: .legs, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Bulgarian Split Squats", category: .legs, numberOfReps: 15, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Bosu Squats", category: .legs, numberOfReps: 15, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Squats", category: .legs, numberOfReps: 24, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Lunges", category: .legs, numberOfReps: 20, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Reverse Lunges", category: .legs, numberOfReps: 20, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Calf raises", category: .legs, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Glute Bridges", category: .legs, numberOfReps: 60, numberOfSets: 3, restSeconds: 90),

        // Handstand
        ExerciseDefinition(name: "Handstand Push-ups", category: .handstand, numberOfReps: 3, numberOfSets: 5, restSeconds: 60),
        ExerciseDefinition(name: "Handstand", category: .handstand, numberOfReps: 15, numberOfSets: 1, restSeconds: 60),
        ExerciseDefinition(name: "Handstand Upper Shift", category: .handstand, numberOfReps: 4, numberOfSets: 5, restSeconds: 60),
        ExerciseDefinition(name: "Handstand Lower Shift", category: .handstand, numberOfReps: 4, numberOfSets: 5, restSeconds: 60),
        ExerciseDefinition(name: "Wall Handstand Shoulder Taps", category: .handstand, numberOfReps: 6, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Wall Walks", category: .handstand, numberOfReps: 6, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Wall Handstand Holds", category: .handstand, numberOfReps: 30, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Crow Pose", category: .handstand, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Pike Push-ups", category: .handstand, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),

        // L-sit
        ExerciseDefinition(name: "L-sits", category: .lSit, numberOfReps: 6, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "L-sit Extensions", category: .lSit, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Tuck L-sit", category: .lSit, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "L-sit Leg Raise Holds", category: .lSit, numberOfReps: 16, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "L-sit Leg Raises", category: .lSit, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Hanging Leg Raise Holds", category: .lSit, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Hanging Leg Raises", category: .lSit, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "L-sit Support Holds", category: .lSit, numberOfReps: 20, numberOfSets: 3, restSeconds: 60),

        // Core
        ExerciseDefinition(name: "Dragon Flag Negatives", category: .core, numberOfReps: 3, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Hanging Leg Raise Holds", category: .core, numberOfReps: 8, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Hanging Leg Raises", category: .core, numberOfReps: 10, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Leg Raises", category: .core, numberOfReps: 18, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Hollow Body Holds", category: .core, numberOfReps: 30, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Planks", category: .core, numberOfReps: 75, numberOfSets: 2, restSeconds: 90),
        ExerciseDefinition(name: "Planks Knee to Elbow", category: .core, numberOfReps: 75, numberOfSets: 2, restSeconds: 90),
        ExerciseDefinition(name: "Side Planks", category: .core, numberOfReps: 45, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Side Splits", category: .core, numberOfReps: 30, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Side Planks Roll Through", category: .core, numberOfReps: 90, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Side Planks Reach Through", category: .core, numberOfReps: 45, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Russian Twists", category: .core, numberOfReps: 20, numberOfSets: 3, restSeconds: 90),

        // Freeze
        ExerciseDefinition(name: "Handstand", category: .freeze, numberOfReps: 10, numberOfSets: 1, restSeconds: 60),
        ExerciseDefinition(name: "Baby", category: .freeze, numberOfReps: 20, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Turtle", category: .freeze, numberOfReps: 20, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Elbow", category: .freeze, numberOfReps: 20, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Pilot", category: .freeze, numberOfReps: 20, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Headstand", category: .freeze, numberOfReps: 30, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Head Bridge", category: .freeze, numberOfReps: 20, numberOfSets: 1, restSeconds: 90),
        ExerciseDefinition(name: "Bridge", category: .freeze, numberOfReps: 20, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Side", category: .freeze, numberOfReps: 20, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Air Baby", category: .freeze, numberOfReps: 8, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Nike", category: .freeze, numberOfReps: 8, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Handstand Hop", category: .freeze, numberOfReps: 6, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Turtle - Headstand", category: .freeze, numberOfReps: 3, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Headstand - Handstand", category: .freeze, numberOfReps: 3, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Turtle - Handstand", category: .freeze, numberOfReps: 1, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Shoulder - Headstand", category: .freeze, numberOfReps: 3, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Baby - Elbow", category: .freeze, numberOfReps: 3, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Elbow - Elbow", category: .freeze, numberOfReps: 3, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Elbow - Handstand", category: .freeze, numberOfReps: 3, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Baby Stack", category: .freeze, numberOfReps: 12, numberOfSets: 3, restSeconds: 90),

        // Power
        ExerciseDefinition(name: "Windmill", category: .power, numberOfReps: 5, numberOfSets: 3, restSeconds: 90),
        ExerciseDefinition(name: "Headspin", category: .power, numberOfReps: 8, numberOfSets: 5, restSeconds: 90),
        ExerciseDefinition(name: "Headmill", category: .power, numberOfReps: 3, numberOfSets: 5, restSeconds: 90),
        ExerciseDefinition(name: "Swipe", category: .power, numberOfReps: 6, numberOfSets: 5, restSeconds: 90),
        ExerciseDefinition(name: "Handglide", category: .power, numberOfReps: 5, numberOfSets: 5, restSeconds: 90),
        ExerciseDefinition(name: "2000", category: .power, numberOfReps: 5, numberOfSets: 5, restSeconds: 90),
        ExerciseDefinition(name: "1990", category: .power, numberOfReps: 5, numberOfSets: 5, restSeconds: 90),
        ExerciseDefinition(name: "Cricket", category: .power, numberOfReps: 8, numberOfSets: 5, restSeconds: 90),

        // Cardio
        ExerciseDefinition(name: "L-sits", category: .cardio, numberOfReps: 20, numberOfSets: 1, restSeconds: 30),
        ExerciseDefinition(name: "Rows", category: .cardio, numberOfReps: 180, numberOfSets: 1, restSeconds: 30),
        ExerciseDefinition(name: "Wall Walks", category: .cardio, numberOfReps: 15, numberOfSets: 1, restSeconds: 30),
        ExerciseDefinition(name: "Bike", category: .cardio, numberOfReps: 180, numberOfSets: 1, restSeconds: 30),
        ExerciseDefinition(name: "Burpee Box Jumps", category: .cardio, numberOfReps: 15, numberOfSets: 1, restSeconds: 30),

        // Popping
        ExerciseDefinition(name: "Arm, Chest, Leg Pop", category: .popping, numberOfReps: 30, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Fresno", category: .popping, numberOfReps: 30, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Body Pop", category: .popping, numberOfReps: 30, numberOfSets: 3, restSeconds: 60),
        ExerciseDefinition(name: "Head, Shoulder, Hip, Leg Roll", category: .popping, numberOfReps: 60, numberOfSets: 3, restSeconds: 30),
        ExerciseDefinition(name: "Arm, Body Wave", category: .popping, numberOfReps: 60, numberOfSets: 3, restSeconds: 30),
        ExerciseDefinition(name: "Head, Neck, Shoulder, Chest, Hip Isolation", category: .popping, numberOfReps: 30, numberOfSets: 3, restSeconds: 30),
        ExerciseDefinition(name: "Arm, Wrist, Finger, Leg Isolation", category: .popping, numberOfReps: 30, numberOfSets: 3, restSeconds: 30),
        ExerciseDefinition(name: "Dime Stop", category: .popping, numberOfReps: 180, numberOfSets: 6, restSeconds: 30),
    ]

    static var exercises: [ExerciseItem] {
        definitions.map { definition in
            ExerciseItem(
                name: definition.name,
                category: definition.category,
                numberOfSets: definition.numberOfSets,
                numberOfReps: definition.numberOfReps,
                restSeconds: definition.restSeconds
            )
        }
    }

    // Increment this when the bundled exercise collection changes.
    private static let version = 7
    private static let installedVersionKey = "database.exerciseContentVersion"

    @discardableResult
    static func installIfNeeded(in modelContext: ModelContext) throws -> Bool {
        let preferences = UserDefaults.standard
        let installedVersion = preferences.integer(
            forKey: installedVersionKey
        )
        guard installedVersion < version else { return false }

        let savedExercises = try modelContext.fetch(FetchDescriptor<ExerciseItem>())

        for savedExercise in savedExercises {
            modelContext.delete(savedExercise)
        }

        for exercise in exercises {
            modelContext.insert(exercise)
        }

        try modelContext.save()
        preferences.set(version, forKey: installedVersionKey)
        return true
    }
}
