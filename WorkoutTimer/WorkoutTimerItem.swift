//
//  WorkoutTimerItem.swift
//  WorkoutTimer
//

import Foundation

struct WorkoutTimerItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var durationSeconds: Int
    var sets: Int
}
