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
    case core = "Core"
    case planche = "Planche"

    var id: String { rawValue }
}

@Model
final class ExerciseItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String
    var notes: String
    var numberOfSets: Int = 3
    var numberOfReps: Int = 10
    var restSeconds: Int = 60
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory = .push,
        notes: String = "",
        numberOfSets: Int = 3,
        numberOfReps: Int = 10,
        restSeconds: Int = 60,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category.rawValue
        self.notes = notes
        self.numberOfSets = numberOfSets
        self.numberOfReps = numberOfReps
        self.restSeconds = restSeconds
        self.updatedAt = updatedAt
    }

    var exerciseCategory: ExerciseCategory {
        get { ExerciseCategory(rawValue: category) ?? .push }
        set { category = newValue.rawValue }
    }
}
