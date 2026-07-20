//
//  WorkoutTimerItem.swift
//  WorkoutTimer
//

import Foundation
import SwiftData

@Model
final class WorkoutTimerItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var durationSeconds: Int
    var sets: Int
    var isPinned: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \TimerExerciseItem.timer)
    var exercises: [TimerExerciseItem] = []
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        durationSeconds: Int,
        sets: Int,
        isPinned: Bool = false,
        exercises: [TimerExerciseItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.durationSeconds = durationSeconds
        self.sets = sets
        self.isPinned = isPinned
        self.exercises = exercises
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var orderedExercises: [TimerExerciseItem] {
        exercises.sorted { $0.position < $1.position }
    }
}
