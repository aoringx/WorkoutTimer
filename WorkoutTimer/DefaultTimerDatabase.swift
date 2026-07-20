//
//  DefaultTimerDatabase.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@MainActor
enum DefaultTimerDatabase {
    struct TimerDefinition {
        let name: String
        let exerciseNames: [String]
    }

    static let timers: [TimerDefinition] = [
        TimerDefinition(
            name: "Planche and Push",
            exerciseNames: [
                "Crow Pose",
                "Tuck Planche",
                "Pseudo Planche Lean",
                "Knee Pseudo Planche Lean",
                "Pseudo Planche Push-Ups",
                "Push-Ups",
                "Dips",
                "Russian Push-Ups",
                "Diamond Push-Ups",
                "Tricep Extensions"
            ]
        ),
        TimerDefinition(
            name: "Pull and Legs",
            exerciseNames: [
                "Assisted Muscle-Ups",
                "Pull-Ups",
                "Assisted Pull-Ups",
                "Inverted Rows",
                "Chin-Ups",
                "Assisted Chin-Ups",
                "Front Lever Rows",
                "Dead Hangs",
                "Pistol Squats",
                "Squats",
                "Lunges",
                "Calf Raises"
            ]
        ),
        TimerDefinition(
            name: "Handstand and Core",
            exerciseNames: [
                "Wall Handstand Holds",
                "Freestanding Handstand Holds",
                "Handstand Shoulder Taps",
                "Handstand Push-Ups",
                "Pike Push-Ups",
                "Tuck L-Sit",
                "L-Sit Extensions",
                "Hanging Leg Raises",
                "Leg Raises",
                "Hollow Body Holds",
                "Planks"
            ]
        )
    ]

    // Increment this when the default timer collection changes.
    private static let version = 1
    private static let installedVersionKey = "database.defaultTimerContentVersion"

    static func installIfNeeded(in modelContext: ModelContext) throws {
        let installedVersion = UserDefaults.standard.integer(
            forKey: installedVersionKey
        )
        guard installedVersion < version else { return }

        let savedTimers = try modelContext.fetch(FetchDescriptor<WorkoutTimerItem>())
        var savedNames = Set(savedTimers.map { $0.name.normalizedForComparison })
        let exercisesByName = Dictionary(
            uniqueKeysWithValues: DefaultExerciseDatabase.exercises.map {
                ($0.name, $0)
            }
        )

        var nextManualSortOrder = (savedTimers.map(\.manualSortOrder).max() ?? -1) + 1

        for timerDefinition in timers {
            guard savedNames.insert(
                timerDefinition.name.normalizedForComparison
            ).inserted else {
                continue
            }

            let timer = try makeTimer(
                from: timerDefinition,
                exercisesByName: exercisesByName,
                manualSortOrder: nextManualSortOrder
            )
            modelContext.insert(timer)
            nextManualSortOrder += 1
        }

        try modelContext.save()
        UserDefaults.standard.set(version, forKey: installedVersionKey)
    }

    private static func makeTimer(
        from definition: TimerDefinition,
        exercisesByName: [String: ExerciseItem],
        manualSortOrder: Int
    ) throws -> WorkoutTimerItem {
        let exercises = try definition.exerciseNames.map { name in
            guard let exercise = exercisesByName[name] else {
                throw InstallationError.missingExercise(name)
            }
            return exercise
        }
        let timerExercises = exercises.enumerated().map { position, exercise in
            TimerExerciseItem(position: position, exercise: exercise)
        }

        return WorkoutTimerItem(
            name: definition.name,
            manualSortOrder: manualSortOrder,
            exercises: timerExercises
        )
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
