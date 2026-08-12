//
//  WorkoutSetCard.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutSetCard: View {
    let exercise: TimerExerciseItem
    let currentSetNumber: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var categoryTint: Color {
        exercise.exerciseCategory.themeTint
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                HStack {
                    ExerciseCategoryBadge(category: exercise.exerciseCategory)

                    Spacer()

                    Label("Set \(currentSetNumber)", systemImage: "flag.fill")
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(categoryTint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(categoryTint.opacity(0.12), in: Capsule())
                }

                Text(exercise.exerciseName)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 10) {
                        metrics
                    }
                } else {
                    HStack(spacing: 10) {
                        metrics
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            categoryTint.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .appSurface(tint: categoryTint, cornerRadius: 22)
        .shadow(color: categoryTint.opacity(0.10), radius: 12, y: 6)
    }

    private var formattedRest: String {
        AppTheme.formattedDuration(exercise.restSeconds)
    }

    @ViewBuilder
    private var metrics: some View {
        WorkoutMetric(
            value: "\(exercise.numberOfReps)",
            label: "Reps / Seconds",
            systemImage: "repeat",
            tint: categoryTint
        )
        WorkoutMetric(
            value: formattedRest,
            label: "Rest Next",
            systemImage: "timer",
            tint: AppTheme.rest
        )
    }
}

private struct WorkoutMetric: View {
    let value: String
    let label: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 62)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            tint.opacity(0.075),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}
