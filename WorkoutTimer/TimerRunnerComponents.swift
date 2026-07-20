//
//  TimerRunnerComponents.swift
//  WorkoutTimer
//

import SwiftUI

struct TimerProgressSection: View {
    let currentExerciseNumber: Int
    let exerciseCount: Int
    let currentSetNumber: Int
    let exerciseSetCount: Int
    let completedSetCount: Int
    let totalSetCount: Int

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

            ProgressView(
                value: Double(completedSetCount),
                total: Double(max(totalSetCount, 1))
            )

            Text("\(completedSetCount) of \(totalSetCount) sets completed")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                TimerMetric(value: "\(exercise.numberOfReps)", label: "Reps")
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
