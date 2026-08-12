//
//  ExerciseSummaryContent.swift
//  WorkoutTimer
//

import SwiftUI

struct ExerciseSummaryContent: View {
    let name: String
    let category: ExerciseCategory
    let sets: Int
    let reps: Int
    let restSeconds: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            ExerciseCategoryBadge(category: category)

            WrappingHStack {
                metricChips
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .layoutPriority(1)
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var metricChips: some View {
        MetricChip(text: "\(sets) sets", systemImage: "square.stack.3d.up")
        MetricChip(text: "\(reps) reps/sec", systemImage: "repeat")
        MetricChip(
            text: AppTheme.formattedDuration(restSeconds),
            systemImage: "timer"
        )
    }
}
