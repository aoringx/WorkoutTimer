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
            ExerciseItem(name: "Pseudo Planche Lean", category: .planche, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Knee Pseudo Planche Lean", category: .planche, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Bent-arm Planche", category: .planche, numberOfSets: 3, numberOfReps: 12, restSeconds: 90),
            ExerciseItem(name: "Pseudo Planche Push-ups", categories: [.planche, .push], numberOfSets: 3, numberOfReps: 8, restSeconds: 60),

            // Push
            ExerciseItem(name: "Dips", category: .push, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Russian Push-ups", category: .push, numberOfSets: 3, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Diamond Push-ups", category: .push, numberOfSets: 3, numberOfReps: 10, restSeconds: 60),
            ExerciseItem(name: "Bar One-arm Push-ups", category: .push, numberOfSets: 3, numberOfReps: 6, restSeconds: 60),
            ExerciseItem(name: "Archer Push-ups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Tricep Extensions", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Explosive Pushups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Weighted Push-ups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Finger Push-ups", category: .push, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Push-ups", category: .push, numberOfSets: 3, numberOfReps: 16, restSeconds: 60),

            // Pull
            ExerciseItem(name: "Assisted Muscle-ups", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Pull-ups", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Pull-up Negatives", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Assisted Pull-ups", category: .pull, numberOfSets: 3, numberOfReps: 5, restSeconds: 60),
            ExerciseItem(name: "Inverted Rows", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Chin-ups", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Chin-up Negatives", category: .pull, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Assisted Chin-ups", category: .pull, numberOfSets: 3, numberOfReps: 5, restSeconds: 60),
            ExerciseItem(name: "Tuck Front Lever", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Assisted Front Lever", category: .pull, numberOfSets: 3, numberOfReps: 10, restSeconds: 60),
            ExerciseItem(name: "Tuck Back Lever", category: .pull, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Dead Hangs", category: .pull, numberOfSets: 3, numberOfReps: 15, restSeconds: 60),

            // Legs
            ExerciseItem(name: "Dragon Squats", category: .legs, numberOfSets: 3, numberOfReps: 1, restSeconds: 90),
            ExerciseItem(name: "Pistol Squats", category: .legs, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Bulgarian Split Squats", category: .legs, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Bosu Squats", category: .legs, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Squats", category: .legs, numberOfSets: 3, numberOfReps: 24, restSeconds: 90),
            ExerciseItem(name: "Lunges", category: .legs, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Reverse Lunges", category: .legs, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Calf raises", category: .legs, numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Glute Bridges", category: .legs, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),

            // Handstand
            ExerciseItem(name: "Handstand Push-ups", categories: [.handstand, .push], numberOfSets: 3, numberOfReps: 3, restSeconds: 30),
            ExerciseItem(name: "Handstand", categories: [.freeze, .handstand], numberOfSets: 3, numberOfReps: 15, restSeconds: 90),
            ExerciseItem(name: "Wall Handstand Shoulder Taps", category: .handstand, numberOfSets: 3, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Wall Walks", categories: [.cardio, .handstand], numberOfSets: 3, numberOfReps: 5, restSeconds: 60),
            ExerciseItem(name: "Wall Handstand Holds", category: .handstand, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Crow Pose", categories: [.handstand, .planche], numberOfSets: 3, numberOfReps: 10, restSeconds: 90),
            ExerciseItem(name: "Pike Push-ups", categories: [.handstand, .push], numberOfSets: 3, numberOfReps: 8, restSeconds: 60),

            // L-sit
            ExerciseItem(name: "L-sits", categories: [.cardio, .lSit], numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "L-sit Extensions", category: .lSit, numberOfSets: 3, numberOfReps: 2, restSeconds: 60),
            ExerciseItem(name: "Tuck L-sit", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "L-sit Leg Raise Holds", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "L-sit Leg Raises", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Hanging Leg Raise Holds", category: .lSit, numberOfSets: 3, numberOfReps: 8, restSeconds: 60),
            ExerciseItem(name: "Hanging Leg Raises", category: .lSit, numberOfSets: 3, numberOfReps: 10, restSeconds: 60),
            ExerciseItem(name: "L-sit Support Holds", category: .lSit, numberOfSets: 3, numberOfReps: 15, restSeconds: 90),

            // Core
            ExerciseItem(name: "Dragon Flag Negatives", category: .core, numberOfSets: 3, numberOfReps: 3, restSeconds: 60),
            ExerciseItem(name: "Leg Raises", category: .core, numberOfSets: 3, numberOfReps: 18, restSeconds: 60),
            ExerciseItem(name: "Hollow Body Holds", category: .core, numberOfSets: 3, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Planks", category: .core, numberOfSets: 2, numberOfReps: 75, restSeconds: 90),
            ExerciseItem(name: "Planks Knee to Elbow", category: .core, numberOfSets: 2, numberOfReps: 75, restSeconds: 90),
            ExerciseItem(name: "Side Planks", category: .core, numberOfSets: 1, numberOfReps: 45, restSeconds: 90),
            ExerciseItem(name: "Side Splits", category: .core, numberOfSets: 1, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Side Planks Roll Through", category: .core, numberOfSets: 1, numberOfReps: 90, restSeconds: 90),
            ExerciseItem(name: "Side Planks Reach Through", category: .core, numberOfSets: 1, numberOfReps: 45, restSeconds: 90),
            ExerciseItem(name: "Russian Twists", category: .core, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),

            // Freeze
            ExerciseItem(name: "Baby", category: .freeze, numberOfSets: 1, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Turtle", category: .freeze, numberOfSets: 1, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Elbow", category: .freeze, numberOfSets: 1, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Pilot", category: .freeze, numberOfSets: 1, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Headstand", category: .freeze, numberOfSets: 1, numberOfReps: 30, restSeconds: 90),
            ExerciseItem(name: "Head Bridge", category: .freeze, numberOfSets: 1, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Bridge", category: .freeze, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Side", category: .freeze, numberOfSets: 3, numberOfReps: 20, restSeconds: 90),
            ExerciseItem(name: "Air Baby", category: .freeze, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Nike", category: .freeze, numberOfSets: 3, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Handstand Hop", category: .freeze, numberOfSets: 3, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Turtle - Headstand", category: .freeze, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Turtle - Handstand", category: .freeze, numberOfSets: 3, numberOfReps: 1, restSeconds: 90),
            ExerciseItem(name: "Shoulder - Headstand", category: .freeze, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Headstand - Handstand", category: .freeze, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Baby - Elbow", category: .freeze, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Elbow - Elbow", category: .freeze, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Elbow - Handstand", category: .freeze, numberOfSets: 3, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "Baby Stack", category: .freeze, numberOfSets: 3, numberOfReps: 12, restSeconds: 90),

            // Power
            ExerciseItem(name: "Windmill", category: .power, numberOfSets: 3, numberOfReps: 5, restSeconds: 90),
            ExerciseItem(name: "Headspin", category: .power, numberOfSets: 5, numberOfReps: 8, restSeconds: 90),
            ExerciseItem(name: "Headmill", category: .power, numberOfSets: 5, numberOfReps: 3, restSeconds: 90),
            ExerciseItem(name: "2000", category: .power, numberOfSets: 5, numberOfReps: 5, restSeconds: 90),
            ExerciseItem(name: "1990", category: .power, numberOfSets: 5, numberOfReps: 5, restSeconds: 90),
            ExerciseItem(name: "Swipe", category: .power, numberOfSets: 5, numberOfReps: 6, restSeconds: 90),
            ExerciseItem(name: "Handglide", category: .power, numberOfSets: 5, numberOfReps: 5, restSeconds: 90),
            ExerciseItem(name: "Cricket", category: .power, numberOfSets: 5, numberOfReps: 8, restSeconds: 90),

            // Cardio
            ExerciseItem(name: "Rows", category: .cardio, numberOfSets: 1, numberOfReps: 300, restSeconds: 30),
            ExerciseItem(name: "Bike", category: .cardio, numberOfSets: 1, numberOfReps: 300, restSeconds: 30),
            ExerciseItem(name: "Burpee Box Jumps", category: .cardio, numberOfSets: 1, numberOfReps: 10, restSeconds: 30)
        ]
    }

    // Increment this when the bundled exercise collection changes.
    private static let version = 3
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
