//
//  ExerciseCategoryBadge.swift
//  WorkoutTimer
//

import SwiftUI

struct ExerciseCategoryBadge: View {
    let category: ExerciseCategory

    var body: some View {
        Text(category.rawValue)
            .font(.caption2.weight(.bold))
            .foregroundStyle(category.themeTint)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(category.themeTint.opacity(0.12), in: Capsule())
    }
}
