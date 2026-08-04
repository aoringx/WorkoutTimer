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
    var additionalCategoryNames: [String]?
    var numberOfSets: Int
    var numberOfReps: Int
    var restSeconds: Int
    var timer: WorkoutTimerItem?

    init(
        id: UUID = UUID(),
        position: Int,
        exerciseName: String,
        categories: [ExerciseCategory],
        numberOfSets: Int,
        numberOfReps: Int,
        restSeconds: Int,
        timer: WorkoutTimerItem? = nil
    ) {
        self.id = id
        self.position = position
        self.exerciseName = exerciseName
        let selectedCategories = Set(categories)
        let orderedCategories = ExerciseCategory.allCases.filter {
            selectedCategories.contains($0)
        }
        let categories = orderedCategories.isEmpty ? [.push] : orderedCategories
        self.category = categories[0].rawValue
        let additionalCategoryNames = categories.dropFirst().map(\.rawValue)
        self.additionalCategoryNames = additionalCategoryNames.isEmpty
            ? nil
            : additionalCategoryNames
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.restSeconds = restSeconds
        self.timer = timer
    }

    convenience init(position: Int, exercise: ExerciseItem) {
        self.init(
            position: position,
            exerciseName: exercise.name,
            categories: exercise.exerciseCategories,
            numberOfSets: exercise.numberOfSets,
            numberOfReps: exercise.numberOfReps,
            restSeconds: exercise.restSeconds
        )
    }

    var exerciseCategories: [ExerciseCategory] {
        let primaryCategory = ExerciseCategory(rawValue: category)
        let additionalNames = Set(additionalCategoryNames ?? [])
        let additionalCategories = ExerciseCategory.allCases.filter {
            $0 != primaryCategory && additionalNames.contains($0.rawValue)
        }
        let categories = (primaryCategory.map { [$0] } ?? [])
            + additionalCategories
        return categories.isEmpty ? [.push] : categories
    }

    var primaryCategory: ExerciseCategory {
        exerciseCategories.first ?? .push
    }
}
