//
//  TimerRunnerComponents.swift
//  WorkoutTimer
//

import SwiftUI

struct TimerRoutinePhaseCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let steps: [String]

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(tint)
                .frame(width: 88, height: 88)
                .background(tint.opacity(0.12), in: Circle())

            VStack(spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())

                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.subheadline.bold())
                            .foregroundStyle(tint)
                            .frame(width: 28, height: 28)
                            .background(tint.opacity(0.12), in: Circle())

                        Text(step)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        }
    }
}

struct TimerProgressSection: View {
    let currentExerciseNumber: Int
    let exerciseCount: Int
    let currentSetNumber: Int
    let exerciseSetCount: Int
    let completedSetCount: Int
    let totalSetCount: Int
    let exerciseNames: [String]
    let currentExerciseIndex: Int
    let selectionAction: (Int) -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Exercise \(currentExerciseNumber) of \(exerciseCount)")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("Set \(currentSetNumber) of \(exerciseSetCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TimerSetProgressExerciseSlider(
                completedSetCount: completedSetCount,
                totalSetCount: totalSetCount,
                exerciseNames: exerciseNames,
                currentExerciseIndex: currentExerciseIndex,
                selectionAction: selectionAction
            )

            HStack {
                Text("\(completedSetCount) of \(totalSetCount) sets completed")

                Spacer()

                Text(exerciseNames[currentExerciseIndex])
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

private struct TimerSetProgressExerciseSlider: View {
    let completedSetCount: Int
    let totalSetCount: Int
    let exerciseNames: [String]
    let currentExerciseIndex: Int
    let selectionAction: (Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let thumbDiameter: CGFloat = 26
            let thumbRadius = thumbDiameter / 2
            let selectableWidth = max(geometry.size.width - thumbDiameter, 0)
            let exerciseFraction = exerciseNames.count > 1
                ? CGFloat(currentExerciseIndex) / CGFloat(exerciseNames.count - 1)
                : 0.5
            let setFraction = min(
                max(CGFloat(completedSetCount) / CGFloat(max(totalSetCount, 1)), 0),
                1
            )

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.2))
                    .frame(height: 5)

                Capsule()
                    .fill(.tint)
                    .frame(
                        width: geometry.size.width * setFraction,
                        height: 5
                    )

                Circle()
                    .fill(.background)
                    .stroke(.tint, lineWidth: 3)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
                    .offset(x: selectableWidth * exerciseFraction)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard exerciseNames.count > 1, selectableWidth > 0 else {
                            return
                        }

                        let fraction = min(
                            max((value.location.x - thumbRadius) / selectableWidth, 0),
                            1
                        )
                        let index = Int(
                            (fraction * CGFloat(exerciseNames.count - 1)).rounded()
                        )
                        selectionAction(index)
                    }
            )
        }
        .frame(height: 28)
        .accessibilityElement()
        .accessibilityLabel("Exercise position and set progress")
        .accessibilityValue(
            "\(exerciseNames[currentExerciseIndex]), "
                + "exercise \(currentExerciseIndex + 1) of \(exerciseNames.count), "
                + "\(completedSetCount) of \(totalSetCount) sets completed"
        )
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                selectionAction(
                    min(currentExerciseIndex + 1, exerciseNames.count - 1)
                )
            case .decrement:
                selectionAction(max(currentExerciseIndex - 1, 0))
            @unknown default:
                break
            }
        }
    }
}

struct TimerSetCard: View {
    let exercise: TimerExerciseItem
    let currentSetNumber: Int

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                Text(exercise.category.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.blue)

                Text(exercise.exerciseName)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("SET \(currentSetNumber)")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }

            HStack(spacing: 10) {
                TimerMetric(value: "\(exercise.numberOfReps)", label: "Reps/Seconds")
                TimerMetric(value: formattedRest, label: "Rest Next")
            }

            if !exercise.notes.isEmpty {
                TimerNotes(text: exercise.notes)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.blue.opacity(0.4), lineWidth: 1)
        }
    }

    private var formattedRest: String {
        guard exercise.restSeconds >= 60 else { return "\(exercise.restSeconds)s" }

        let minutes = exercise.restSeconds / 60
        let remainingSeconds = exercise.restSeconds % 60
        return remainingSeconds == 0
            ? "\(minutes)m"
            : "\(minutes)m \(remainingSeconds)s"
    }
}

struct TimerRestCard: View {
    let exercise: TimerExerciseItem
    let remainingRestSeconds: Int
    let destinationDescription: String

    var body: some View {
        VStack(spacing: 18) {
            Text("REST")
                .font(.headline)
                .foregroundStyle(.red)

            Text(formattedCountdown)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(.red)

            Text(remainingRestSeconds == 0 ? "Rest complete" : destinationDescription)
                .font(.headline)
                .foregroundStyle(remainingRestSeconds == 0 ? .green : .secondary)

            ProgressView(
                value: Double(max(exercise.restSeconds - remainingRestSeconds, 0)),
                total: Double(max(exercise.restSeconds, 1))
            )
            .tint(.red)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.red.opacity(0.4), lineWidth: 1)
        }
    }

    private var formattedCountdown: String {
        String(format: "%d:%02d", remainingRestSeconds / 60, remainingRestSeconds % 60)
    }
}

struct TimerUpNextCard: View {
    let exercise: TimerExerciseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("UP NEXT")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(exercise.exerciseName)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct TimerNotes: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NOTES")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct TimerMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }
}
