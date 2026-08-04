//
//  WorkoutRunnerComponents.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutPhaseCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let steps: [String]

    var body: some View {
        VStack(spacing: 26) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
                .shadow(color: tint.opacity(0.24), radius: 16, y: 8)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .monospacedDigit()
                            .foregroundStyle(tint)
                            .frame(width: 30, height: 30)
                            .background(tint.opacity(0.13), in: Circle())

                        Text(step)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(26)
        .background(
            tint.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .appSurface(tint: tint, cornerRadius: 28)
        .shadow(color: tint.opacity(0.10), radius: 18, y: 10)
    }
}

struct WorkoutProgressSection: View {
    let currentExerciseNumber: Int
    let exerciseCount: Int
    let currentSetNumber: Int
    let exerciseSetCount: Int
    let completedSetCount: Int
    let totalSetCount: Int
    let exerciseNames: [String]
    let currentExerciseIndex: Int
    let currentSetIndex: Int
    let tint: Color
    let selectionAction: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    exerciseProgressLabel

                    Spacer(minLength: 8)

                    setProgressBadge
                }

                VStack(alignment: .leading, spacing: 5) {
                    exerciseProgressLabel
                    setProgressBadge
                }
            }

            WorkoutSetProgressSlider(
                completedSetCount: completedSetCount,
                totalSetCount: totalSetCount,
                exerciseNames: exerciseNames,
                currentExerciseIndex: currentExerciseIndex,
                currentSetIndex: currentSetIndex,
                tint: tint,
                selectionAction: selectionAction
            )

            ViewThatFits(in: .horizontal) {
                HStack {
                    completedProgressText

                    Spacer(minLength: 8)

                    currentExerciseName
                }

                VStack(alignment: .leading, spacing: 4) {
                    completedProgressText
                    currentExerciseName
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            tint.opacity(0.045),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .appSurface(tint: tint, cornerRadius: 18)
    }

    private var exerciseProgressLabel: some View {
        Label(
            "Exercise \(currentExerciseNumber) of \(exerciseCount)",
            systemImage: "figure.strengthtraining.traditional"
        )
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.primary)
    }

    private var setProgressBadge: some View {
        Text("Set \(currentSetNumber) of \(exerciseSetCount)")
            .font(.caption.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.12), in: Capsule())
    }

    private var completedProgressText: some View {
        Text("\(completedSetCount) of \(totalSetCount) sets complete")
            .monospacedDigit()
    }

    private var currentExerciseName: some View {
        Text(exerciseNames[currentExerciseIndex])
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

private struct WorkoutSetProgressSlider: View {
    let completedSetCount: Int
    let totalSetCount: Int
    let exerciseNames: [String]
    let currentExerciseIndex: Int
    let currentSetIndex: Int
    let tint: Color
    let selectionAction: (Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let thumbDiameter: CGFloat = 30
            let thumbRadius = thumbDiameter / 2
            let selectableWidth = max(geometry.size.width - thumbDiameter, 0)
            let currentSetFraction = totalSetCount > 1
                ? CGFloat(currentSetIndex) / CGFloat(totalSetCount - 1)
                : 0.5
            let completedFraction = min(
                max(CGFloat(completedSetCount) / CGFloat(max(totalSetCount, 1)), 0),
                1
            )

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.16))
                    .frame(width: selectableWidth, height: 7)
                    .offset(x: thumbRadius)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.72)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: selectableWidth * completedFraction,
                        height: 7
                    )
                    .offset(x: thumbRadius)

                if totalSetCount > 1, totalSetCount <= 12 {
                    ForEach(0..<totalSetCount, id: \.self) { index in
                        let fraction = CGFloat(index) / CGFloat(totalSetCount - 1)

                        Circle()
                            .fill(
                                index < completedSetCount
                                    ? AnyShapeStyle(.white.opacity(0.88))
                                    : AnyShapeStyle(.secondary.opacity(0.38))
                            )
                            .frame(width: 4, height: 4)
                            .offset(
                                x: thumbRadius + selectableWidth * fraction - 2
                            )
                    }
                }

                Circle()
                    .fill(.background)
                    .overlay {
                        Circle()
                            .fill(tint.opacity(0.10))
                    }
                    .overlay {
                        Circle()
                            .stroke(tint, lineWidth: 3)
                    }
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .shadow(color: tint.opacity(0.25), radius: 5, y: 2)
                    .offset(x: selectableWidth * currentSetFraction)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard totalSetCount > 1, selectableWidth > 0 else {
                            return
                        }

                        let fraction = min(
                            max((value.location.x - thumbRadius) / selectableWidth, 0),
                            1
                        )
                        let index = Int(
                            (fraction * CGFloat(totalSetCount - 1)).rounded()
                        )
                        selectionAction(index)
                    }
            )
        }
        .frame(minHeight: 44)
        .accessibilityElement()
        .accessibilityLabel("Set position and workout progress")
        .accessibilityValue(
            "\(exerciseNames[currentExerciseIndex]), "
                + "workout set \(currentSetIndex + 1) of \(totalSetCount), "
                + "\(completedSetCount) of \(totalSetCount) sets completed"
        )
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                selectionAction(
                    min(currentSetIndex + 1, totalSetCount - 1)
                )
            case .decrement:
                selectionAction(max(currentSetIndex - 1, 0))
            @unknown default:
                break
            }
        }
    }
}

struct WorkoutSetCard: View {
    let exercise: TimerExerciseItem
    let currentSetNumber: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var categoryTint: Color {
        exercise.primaryCategory.themeTint
    }

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 6) {
                HStack {
                    ExerciseCategoryBadges(categories: exercise.exerciseCategories)

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

struct WorkoutUpNextCard: View {
    let title: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "forward.end.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(
                    tint.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("UP NEXT")
                    .font(.caption2.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .appSurface(tint: tint, cornerRadius: 16)
        .accessibilityElement(children: .combine)
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

struct WorkoutControlBar<Content: View>: View {
    let tint: Color
    private let content: Content

    init(
        tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: 680)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.clear, tint.opacity(0.42), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
            }
    }
}
