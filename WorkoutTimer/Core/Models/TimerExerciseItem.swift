//
//  TimerExerciseItem.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@Model
final class TimerExerciseItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var position: Int
    var exerciseName: String
    var category: String
    // Retained so existing SwiftData stores can migrate without a schema break.
    // New and upgraded records always clear this legacy multi-type field.
    var additionalCategoryNames: [String]?
    var numberOfSets: Int
    var numberOfReps: Int
    var restSeconds: Int
    var timer: WorkoutTimerItem?

    init(
        id: UUID = UUID(),
        position: Int,
        exerciseName: String,
        category: ExerciseCategory,
        numberOfSets: Int,
        numberOfReps: Int,
        restSeconds: Int,
        timer: WorkoutTimerItem? = nil
    ) {
        self.id = id
        self.position = position
        self.exerciseName = exerciseName
        self.category = category.rawValue
        self.additionalCategoryNames = nil
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.restSeconds = restSeconds
        self.timer = timer
    }

    convenience init(position: Int, exercise: ExerciseItem) {
        self.init(
            position: position,
            exerciseName: exercise.name,
            category: exercise.exerciseCategory,
            numberOfSets: exercise.numberOfSets,
            numberOfReps: exercise.numberOfReps,
            restSeconds: exercise.restSeconds
        )
    }

    var exerciseCategory: ExerciseCategory {
        get {
            ExerciseCategory(rawValue: category) ?? .push
        }
        set {
            category = newValue.rawValue
            additionalCategoryNames = nil
        }
    }
}
