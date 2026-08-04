//
//  WorkoutProgressSection.swift
//  WorkoutTimer
//

import SwiftUI

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
