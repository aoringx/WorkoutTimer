//
//  SavedWorkoutRow.swift
//  WorkoutTimer
//

import SwiftUI

struct SavedWorkoutRow: View {
    let timer: WorkoutTimerItem

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: "timer")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    AppTheme.brandGradient,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(timer.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 4)

                    if timer.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.energy)
                            .accessibilityLabel("Pinned")
                    }
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) {
                        metricChips
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        metricChips
                    }
                }

                Label {
                    Text(
                        timer.updatedAt,
                        format: .dateTime.month(.abbreviated).day().year()
                    )
                } icon: {
                    Image(systemName: "clock")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var metricChips: some View {
        if timer.isCategoryWorkout {
            MetricChip(
                text: "Automatic",
                systemImage: "arrow.triangle.2.circlepath"
            )
        }
        MetricChip(
            text: "\(timer.exercises.count) exercises",
            systemImage: "figure.strengthtraining.traditional"
        )
        MetricChip(
            text: "\(timer.sets) sets",
            systemImage: "square.stack.3d.up"
        )
    }
}
