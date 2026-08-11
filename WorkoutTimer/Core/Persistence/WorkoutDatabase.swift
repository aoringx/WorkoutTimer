//
//  WorkoutDatabase.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@MainActor
enum WorkoutDatabase {
    private struct WorkoutDefinition {
        let category: ExerciseCategory
        let exerciseNames: [String]
    }

    private static let workouts = [
        WorkoutDefinition(
            category: .planche,
            exerciseNames: [
                "Tuck Planche",
                "Pseudo Planche Lean",
                "Knee Pseudo Planche Lean",
                "Bent-arm Planche",
                "Crow Pose",
                "Pseudo Planche Push-ups"
            ]
        ),
        WorkoutDefinition(
            category: .push,
            exerciseNames: [
                "Handstand Push-ups",
                "Pike Push-ups",
                "Pseudo Planche Push-ups",
                "Dips",
                "Russian Push-ups",
                "Diamond Push-ups",
                "Bar One-arm Push-ups",
                "Archer Push-ups",
                "Explosive Pushups",
                "Weighted Push-ups",
                "Finger Push-ups",
                "Tricep Extensions",
                "Push-ups"
            ]
        ),
        WorkoutDefinition(
            category: .pull,
            exerciseNames: [
                "Assisted Muscle-ups",
                "Pull-ups",
                "Assisted Pull-ups",
                "Pull-up Negatives",
                "Chin-ups",
                "Assisted Chin-ups",
                "Chin-up Negatives",
                "Inverted Rows",
                "Tuck Front Lever",
                "Assisted Front Lever",
                "Tuck Back Lever",
                "Dead Hangs"
            ]
        ),
        WorkoutDefinition(
            category: .legs,
            exerciseNames: [
                "Dragon Squats",
                "Pistol Squats",
                "Bulgarian Split Squats",
                "Bosu Squats",
                "Squats",
                "Lunges",
                "Reverse Lunges",
                "Calf raises",
                "Glute Bridges"
            ]
        ),
        WorkoutDefinition(
            category: .handstand,
            exerciseNames: [
                "Handstand Push-ups",
                "Handstands",
                "Wall Handstand Shoulder Taps",
                "Wall Walks",
                "Wall Handstand Holds",
                "Crow Pose",
                "Pike Push-ups"
            ]
        ),
        WorkoutDefinition(
            category: .lSit,
            exerciseNames: [
                "L-sits",
                "L-sit Extensions",
                "Tuck L-sit",
                "L-sit Leg Raise Holds",
                "L-sit Leg Raises",
                "Hanging Leg Raise Holds",
                "Hanging Leg Raises",
                "L-sit Support Holds"
            ]
        ),
        WorkoutDefinition(
            category: .core,
            exerciseNames: [
                "Dragon Flag Negatives",
                "Leg Raises",
                "Hollow Body Holds",
                "Planks",
                "Planks Knee to Elbow",
                "Side Planks",
                "Side Splits",
                "Side Planks Roll Through",
                "Side Planks Reach Through",
                "Russian Twists"
            ]
        ),
        WorkoutDefinition(
            category: .freeze,
            exerciseNames: [
                "Handstand",
                "Baby",
                "Turtle",
                "Elbow",
                "Pilot",
                "Headstand",
                "Head Bridge",
                "Bridge",
                "Side",
                "Air Baby",
                "Nike",
                "Handstand Hop",
                "Turtle - Headstand",
                "Turtle - Handstand",
                "Shoulder - Headstand",
                "Headstand - Handstand",
                "Baby - Elbow",
                "Elbow - Elbow",
                "Elbow - Handstand",
                "Baby Stack"
            ]
        ),
        WorkoutDefinition(
            category: .power,
            exerciseNames: [
                "Windmill",
                "Headspin",
                "Headmill",
                "2000",
                "1990",
                "Swipe",
                "Handglide",
                "Cricket"
            ]
        ),
        WorkoutDefinition(
            category: .cardio,
            exerciseNames: [
                "Bike",
                "L-sits",
                "Rows",
                "Burpee Box Jumps",
                "Wall Walks"
            ]
        )
    ]

    // Increment this when a category workout definition or order changes.
    private static let version = 3
    private static let installedVersionKey = "database.workoutContentVersion"

    static func installIfNeeded(
        in modelContext: ModelContext,
        forceRebuild: Bool = false
    ) throws {
        let preferences = UserDefaults.standard
        let installedVersion = preferences.integer(
            forKey: installedVersionKey
        )
        guard forceRebuild || installedVersion < version else { return }

        if forceRebuild {
            preferences.removeObject(forKey: installedVersionKey)
        }

        try rebuild(in: modelContext)
        try modelContext.save()
        preferences.set(version, forKey: installedVersionKey)
    }

    static func rebuild(in modelContext: ModelContext) throws {
        let exercises = try modelContext.fetch(FetchDescriptor<ExerciseItem>())
        let savedWorkouts = try modelContext.fetch(
            FetchDescriptor<WorkoutTimerItem>()
        )

        var nextManualSortOrder =
            (savedWorkouts.map(\.manualSortOrder).max() ?? -1) + 1

        for workoutDefinition in workouts {
            let category = workoutDefinition.category
            let categoryExercises = exercises
                .filter { $0.exerciseCategories.contains(category) }
            let orderedExercises = ordered(
                categoryExercises,
                using: workoutDefinition
            )

            let categoryWorkouts = savedWorkouts.filter {
                $0.categoryWorkoutCategory == category
            }

            let workout: WorkoutTimerItem
            if let savedWorkout = categoryWorkouts.first {
                workout = savedWorkout
            } else {
                workout = WorkoutTimerItem(
                    name: category.rawValue,
                    manualSortOrder: nextManualSortOrder,
                    categoryName: category.rawValue
                )
                modelContext.insert(workout)
                nextManualSortOrder += 1
            }

            for duplicate in categoryWorkouts.dropFirst() {
                modelContext.delete(duplicate)
            }

            let previousExercises = workout.exercises
            let generatedExercises = orderedExercises.enumerated().map {
                position, exercise in
                TimerExerciseItem(position: position, exercise: exercise)
            }

            workout.name = category.rawValue
            workout.categoryName = category.rawValue
            workout.exercises = generatedExercises
            workout.updatedAt = Date()

            for exercise in generatedExercises {
                exercise.timer = workout
            }

            for exercise in previousExercises {
                modelContext.delete(exercise)
            }
        }
    }

    private static func ordered(
        _ exercises: [ExerciseItem],
        using definition: WorkoutDefinition
    ) -> [ExerciseItem] {
        let orderByName = Dictionary(
            definition.exerciseNames.enumerated().map { index, name in
                (name.normalizedForComparison, index)
            },
            uniquingKeysWith: min
        )

        return exercises.sorted { first, second in
            let firstOrder = orderByName[
                first.name.normalizedForComparison
            ] ?? Int.max
            let secondOrder = orderByName[
                second.name.normalizedForComparison
            ] ?? Int.max

            if firstOrder != secondOrder {
                return firstOrder < secondOrder
            }

            return first.name.localizedStandardCompare(second.name)
                == .orderedAscending
        }
    }
}
