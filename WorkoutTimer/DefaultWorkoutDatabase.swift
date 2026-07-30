//
//  DefaultWorkoutDatabase.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@MainActor
enum DefaultWorkoutDatabase {
    struct WorkoutDefinition {
        let name: String
        let exerciseNames: [String]
    }

    static let workouts: [WorkoutDefinition] = [
        WorkoutDefinition(
            name: "Planche",
            exerciseNames: [
                "Tuck Planche",
                "Pseudo Planche Lean",
                "Knee Pseudo Planche Lean",
                "Bent-arm Planche",
                "Crow Pose",
                "Pseudo Planche Push-Ups"
            ]
        ),
        WorkoutDefinition(
            name: "Push",
            exerciseNames: [
                "Handstand Push-Ups",
                "Pike Push-Ups",
                "Dips",
                "Russian Push-Ups",
                "Diamond Push-Ups",
                "Tricep Extensions",
                "Push-Ups"
            ]
        ),
        WorkoutDefinition(
            name: "Pull",
            exerciseNames: [
                "Assisted Muscle-Ups",
                "Pull-Ups",
                "Assisted Pull-Ups",
                "Pull-Up Negatives",
                "Inverted Rows",
                "Tuck Front Lever",
                "Assisted Front Lever",
                "Dead Hangs"
            ]
        ),
        WorkoutDefinition(
            name: "Legs",
            exerciseNames: [
                "Pistol Squats",
                "Bulgarian split squats",
                "Reverse Lunges",
                "Calf Raises",
                "Glute bridges"
            ]
        ),
        WorkoutDefinition(
            name: "Handstand",
            exerciseNames: [
                "Handstand Push-Ups",
                "Freestanding Handstand Holds",
                "Wall Handstand Shoulder Taps",
                "Wall Handstand Holds",
                "Crow Pose",
                "Pike Push-Ups"
            ]
        ),
        WorkoutDefinition(
            name: "Core",
            exerciseNames: [
                "L-Sit Extensions",
                "Tuck L-Sit",
                "L-Sit Leg Raises",
                "Hanging Leg Raises",
                "Leg Raises",
                "Hollow Body Holds",
                "Planks"
            ]
        )
    ]

    // Increment this when the default workout collection changes.
    private static let version = 7
    private static let installedVersionKey = "database.defaultTimerContentVersion"

    static func installIfNeeded(in modelContext: ModelContext) throws {
        let installedVersion = UserDefaults.standard.integer(
            forKey: installedVersionKey
        )
        guard installedVersion < version else { return }

        let savedWorkouts = try modelContext.fetch(FetchDescriptor<WorkoutTimerItem>())
        let savedWorkoutsByName = Dictionary(
            grouping: savedWorkouts,
            by: { $0.name.normalizedForComparison }
        )
        let exercisesByName = Dictionary(
            uniqueKeysWithValues: DefaultExerciseDatabase.exercises.map {
                ($0.name, $0)
            }
        )
        let shouldInstallMissingDefaults = installedVersion == 0
            && savedWorkouts.isEmpty

        var nextManualSortOrder = (savedWorkouts.map(\.manualSortOrder).max() ?? -1) + 1

        for workoutDefinition in workouts {
            let normalizedName = workoutDefinition.name.normalizedForComparison

            if let matchingWorkouts = savedWorkoutsByName[normalizedName] {
                for savedWorkout in matchingWorkouts {
                    try overwrite(
                        savedWorkout,
                        with: workoutDefinition,
                        exercisesByName: exercisesByName,
                        in: modelContext
                    )
                }
            } else if shouldInstallMissingDefaults {
                let workout = try makeWorkout(
                    from: workoutDefinition,
                    exercisesByName: exercisesByName,
                    manualSortOrder: nextManualSortOrder
                )
                modelContext.insert(workout)
                nextManualSortOrder += 1
            }
        }

        try modelContext.save()
        UserDefaults.standard.set(version, forKey: installedVersionKey)
    }

    private static func makeWorkout(
        from definition: WorkoutDefinition,
        exercisesByName: [String: ExerciseItem],
        manualSortOrder: Int
    ) throws -> WorkoutTimerItem {
        return WorkoutTimerItem(
            name: definition.name,
            manualSortOrder: manualSortOrder,
            exercises: try makeWorkoutExercises(
                from: definition,
                exercisesByName: exercisesByName
            )
        )
    }

    private static func overwrite(
        _ savedWorkout: WorkoutTimerItem,
        with definition: WorkoutDefinition,
        exercisesByName: [String: ExerciseItem],
        in modelContext: ModelContext
    ) throws {
        let oldExercises = savedWorkout.exercises
        let updatedExercises = try makeWorkoutExercises(
            from: definition,
            exercisesByName: exercisesByName
        )

        savedWorkout.name = definition.name
        savedWorkout.exercises = updatedExercises

        for exercise in updatedExercises {
            exercise.timer = savedWorkout
        }
        for exercise in oldExercises {
            modelContext.delete(exercise)
        }
    }

    private static func makeWorkoutExercises(
        from definition: WorkoutDefinition,
        exercisesByName: [String: ExerciseItem]
    ) throws -> [TimerExerciseItem] {
        try definition.exerciseNames.enumerated().map { position, name in
            guard let exercise = exercisesByName[name] else {
                throw InstallationError.missingExercise(name)
            }
            return TimerExerciseItem(position: position, exercise: exercise)
        }
    }

    private enum InstallationError: LocalizedError {
        case missingExercise(String)

        var errorDescription: String? {
            switch self {
            case .missingExercise(let name):
                "The default exercise \"\(name)\" could not be found."
            }
        }
    }
}
