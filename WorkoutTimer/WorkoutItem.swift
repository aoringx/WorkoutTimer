//
//  WorkoutItem.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@Model
final class WorkoutTimerItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var isPinned: Bool = false
    var manualSortOrder: Int = 0
    @Relationship(deleteRule: .cascade, inverse: \TimerExerciseItem.timer)
    var exercises: [TimerExerciseItem] = []
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        isPinned: Bool = false,
        manualSortOrder: Int = 0,
        exercises: [TimerExerciseItem] = [],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.isPinned = isPinned
        self.manualSortOrder = manualSortOrder
        self.exercises = exercises
        self.updatedAt = updatedAt
    }

    var sets: Int {
        exercises.reduce(0) { $0 + $1.numberOfSets }
    }

    var orderedExercises: [TimerExerciseItem] {
        exercises.sorted { $0.position < $1.position }
    }
}
