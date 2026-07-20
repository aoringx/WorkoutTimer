//
//  AppSettings.swift
//  WorkoutTimer
//

import Foundation

enum AppSettingKey {
    static let soundEnabled = "settings.soundEnabled"
    static let countdownBeepsEnabled = "settings.countdownBeepsEnabled"
    static let hapticsEnabled = "settings.hapticsEnabled"
    static let autoStartNextSet = "settings.autoStartNextSet"
    static let keepScreenAwake = "settings.keepScreenAwake"
    static let defaultSets = "settings.defaultSets"
    static let defaultReps = "settings.defaultReps"
    static let defaultRestSeconds = "settings.defaultRestSeconds"
}

enum AppSettingDefault {
    static let soundEnabled = true
    static let countdownBeepsEnabled = true
    static let hapticsEnabled = true
    static let autoStartNextSet = false
    static let keepScreenAwake = true
    static let sets = 3
    static let reps = 5
    static let restSeconds = 60
}
