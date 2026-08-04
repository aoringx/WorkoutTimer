//
//  AppTheme.swift
//  WorkoutTimer
//

import SwiftUI

enum AppTheme {
    static let brand = Color(red: 0.31, green: 0.27, blue: 0.90)
    static let electricBlue = Color(red: 0.12, green: 0.55, blue: 0.98)
    static let energy = Color(red: 0.96, green: 0.47, blue: 0.18)
    static let success = Color(red: 0.12, green: 0.68, blue: 0.42)
    static let rest = Color(red: 0.93, green: 0.28, blue: 0.33)

    static let brandGradient = LinearGradient(
        colors: [brand, electricBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func formattedDuration(_ seconds: Int) -> String {
        guard seconds >= 60 else { return "\(seconds)s" }

        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return remainingSeconds == 0
            ? "\(minutes)m"
            : "\(minutes)m \(remainingSeconds)s"
    }
}
