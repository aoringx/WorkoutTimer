//
//  ExerciseItem.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

enum ExerciseCategory: String, CaseIterable, Identifiable {
    case handstand = "Handstand"
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case lSit = "L-sit"
    case core = "Core"
    case planche = "Planche"
    case freeze = "Freeze"
    case power = "Power"
    case cardio = "Cardio"

    var id: String { rawValue }
}

@Model
final class ExerciseItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var additionalCategoryNames: [String]?
    var numberOfSets: Int = 3
    var numberOfReps: Int = 10
    var restSeconds: Int = 60
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        categories: [ExerciseCategory],
        numberOfSets: Int = 3,
        numberOfReps: Int = 10,
        restSeconds: Int = 60,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
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
        self.updatedAt = updatedAt
    }

    convenience init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory = .push,
        numberOfSets: Int = 3,
        numberOfReps: Int = 10,
        restSeconds: Int = 60,
        updatedAt: Date = Date()
    ) {
        self.init(
            id: id,
            name: name,
            categories: [category],
            numberOfSets: numberOfSets,
            numberOfReps: numberOfReps,
            restSeconds: restSeconds,
            updatedAt: updatedAt
        )
    }

    var exerciseCategories: [ExerciseCategory] {
        get {
            let primaryCategory = ExerciseCategory(rawValue: category)
            let additionalNames = Set(additionalCategoryNames ?? [])
            let additionalCategories = ExerciseCategory.allCases.filter {
                $0 != primaryCategory && additionalNames.contains($0.rawValue)
            }
            let categories = (primaryCategory.map { [$0] } ?? [])
                + additionalCategories
            return categories.isEmpty ? [.push] : categories
        }
        set {
            let selectedCategories = Set(newValue)
            let categories = ExerciseCategory.allCases.filter {
                selectedCategories.contains($0)
            }
            let resolvedCategories = categories.isEmpty ? [.push] : categories
            category = resolvedCategories[0].rawValue
            let additionalNames = resolvedCategories.dropFirst().map(\.rawValue)
            additionalCategoryNames = additionalNames.isEmpty
                ? nil
                : additionalNames
        }
    }

    var primaryCategory: ExerciseCategory {
        exerciseCategories.first ?? .push
    }
}
