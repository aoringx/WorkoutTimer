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
    // Retained so existing SwiftData stores can migrate without a schema break.
    // New and upgraded records always clear this legacy multi-type field.
    var additionalCategoryNames: [String]?
    var numberOfSets: Int = 3
    var numberOfReps: Int = 10
    var restSeconds: Int = 60
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory = .push,
        numberOfSets: Int = 3,
        numberOfReps: Int = 10,
        restSeconds: Int = 60,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category.rawValue
        self.additionalCategoryNames = nil
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.restSeconds = restSeconds
        self.updatedAt = updatedAt
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
