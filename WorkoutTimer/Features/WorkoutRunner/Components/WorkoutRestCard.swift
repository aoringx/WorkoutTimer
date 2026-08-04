//
//  WorkoutRestCard.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutRestCard: View {
    let exercise: TimerExerciseItem
    let remainingRestSeconds: Int
    let destinationDescription: String

    @ScaledMetric(relativeTo: .largeTitle)
    private var countdownFontSize: CGFloat = 52

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Label("REST", systemImage: "moon.zzz.fill")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.rest)

                Spacer()

                Text(exercise.exerciseName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text(formattedCountdown)
                .font(
                    .system(
                        size: min(countdownFontSize, 72),
                        weight: .bold,
                        design: .rounded
                    )
                )
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(AppTheme.rest)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(remainingRestSeconds == 0 ? "Rest complete" : destinationDescription)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    remainingRestSeconds == 0
                        ? AnyShapeStyle(AppTheme.success)
                        : AnyShapeStyle(.secondary)
                )
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            ProgressView(
                value: Double(max(exercise.restSeconds - remainingRestSeconds, 0)),
                total: Double(max(exercise.restSeconds, 1))
            )
            .tint(AppTheme.rest)
            .scaleEffect(y: 1.45)
            .accessibilityLabel("Rest progress")
            .accessibilityValue(
                remainingRestSeconds == 0
                    ? "Complete"
                    : "\(remainingRestSeconds) seconds remaining"
            )
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(
            AppTheme.rest.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .appSurface(tint: AppTheme.rest, cornerRadius: 22)
        .shadow(color: AppTheme.rest.opacity(0.10), radius: 12, y: 6)
    }

    private var formattedCountdown: String {
        String(format: "%d:%02d", remainingRestSeconds / 60, remainingRestSeconds % 60)
    }
}
