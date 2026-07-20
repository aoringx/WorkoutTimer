//
//  TimerRunnerView.swift
//  WorkoutTimer
//

import SwiftUI
import UIKit

struct TimerRunnerView: View {
    private enum RunPhase: String {
        case exerciseSet
        case rest
    }

    // MARK: - Dependencies and Settings

    @Environment(\.dismiss) private var dismiss

    @AppStorage(AppSettingKey.soundEnabled)
    private var soundEnabled = AppSettingDefault.soundEnabled

    @AppStorage(AppSettingKey.countdownBeepsEnabled)
    private var countdownBeepsEnabled = AppSettingDefault.countdownBeepsEnabled

    @AppStorage(AppSettingKey.hapticsEnabled)
    private var hapticsEnabled = AppSettingDefault.hapticsEnabled

    @AppStorage(AppSettingKey.autoStartNextSet)
    private var autoStartNextSet = AppSettingDefault.autoStartNextSet

    @AppStorage(AppSettingKey.keepScreenAwake)
    private var keepScreenAwake = AppSettingDefault.keepScreenAwake

    let timer: WorkoutTimerItem

    // MARK: - Session State

    @State private var currentExerciseIndex = 0
    @State private var currentSetNumber = 1
    @State private var phase = RunPhase.exerciseSet
    @State private var remainingRestSeconds = 0
    @State private var restCountdownID = UUID()
    @State private var isFinished = false
    @State private var previousIdleTimerDisabled = false

    // MARK: - Session Progress

    private var exercises: [TimerExerciseItem] {
        timer.orderedExercises
    }

    private var currentExercise: TimerExerciseItem? {
        guard exercises.indices.contains(currentExerciseIndex) else { return nil }
        return exercises[currentExerciseIndex]
    }

    private var nextExercise: TimerExerciseItem? {
        let nextIndex = currentExerciseIndex + 1
        guard exercises.indices.contains(nextIndex) else { return nil }
        return exercises[nextIndex]
    }

    private var totalSetCount: Int {
        exercises.reduce(0) { $0 + max($1.numberOfSets, 1) }
    }

    private var completedSetCount: Int {
        let completedExercises = exercises.prefix(currentExerciseIndex).reduce(0) {
            $0 + max($1.numberOfSets, 1)
        }
        let completedCurrentSets = max(currentSetNumber - 1, 0)
            + (phase == .rest ? 1 : 0)
        return completedExercises + completedCurrentSets
    }

    // MARK: - View

    var body: some View {
        Group {
            if exercises.isEmpty {
                emptyState
            } else if isFinished {
                completedState
            } else if let currentExercise {
                exerciseScreen(currentExercise)
            }
        }
        .navigationTitle(timer.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: restCountdownID) {
            await runRestCountdown()
        }
        .onAppear {
            previousIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
            applyScreenAwakeSetting()
        }
        .onChange(of: keepScreenAwake) {
            applyScreenAwakeSetting()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = previousIdleTimerDisabled
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Exercises",
            systemImage: "list.bullet",
            description: Text("Add exercises to this timer from Manage Timers.")
        )
    }

    private func exerciseScreen(_ exercise: TimerExerciseItem) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                TimerProgressSection(
                    currentExerciseNumber: currentExerciseIndex + 1,
                    exerciseCount: exercises.count,
                    currentSetNumber: currentSetNumber,
                    exerciseSetCount: max(exercise.numberOfSets, 1),
                    completedSetCount: completedSetCount,
                    totalSetCount: totalSetCount
                )

                if phase == .exerciseSet {
                    TimerSetCard(
                        exercise: exercise,
                        currentSetNumber: currentSetNumber
                    )
                } else {
                    TimerRestCard(
                        exercise: exercise,
                        remainingRestSeconds: remainingRestSeconds,
                        destinationDescription: restDestinationDescription(for: exercise)
                    )
                }

                if phase == .exerciseSet,
                   currentSetNumber >= max(exercise.numberOfSets, 1),
                   let nextExercise {
                    TimerUpNextCard(exercise: nextExercise)
                }
            }
            .padding()
            .padding(.bottom, 88)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if canGoBack {
                    Button {
                        goBackOneStep()
                    } label: {
                        Label(previousButtonTitle, systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button {
                    handlePrimaryAction(for: exercise)
                } label: {
                    Text(primaryButtonTitle(for: exercise))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .background(.bar)
        }
        .tint(phase == .rest ? .red : .blue)
    }

    private var completedState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)

            Text("Timer Complete")
                .font(.largeTitle.bold())

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)

            Button("Back to Last Set", systemImage: "arrow.uturn.backward") {
                returnToLastSet()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }

    // MARK: - Controls

    private var canGoBack: Bool {
        phase == .rest || currentSetNumber > 1 || currentExerciseIndex > 0
    }

    private var previousButtonTitle: String {
        if phase == .rest {
            return "Back to Set \(currentSetNumber)"
        } else if currentSetNumber > 1 {
            return "Previous Set"
        } else {
            return "Previous Exercise"
        }
    }

    private func primaryButtonTitle(for exercise: TimerExerciseItem) -> String {
        if phase == .rest {
            if remainingRestSeconds > 0 {
                return "Skip Rest"
            }

            if currentSetNumber >= max(exercise.numberOfSets, 1) {
                return currentExerciseIndex == exercises.count - 1
                    ? "Finish"
                    : "Next Exercise"
            }

            return "Start Set \(currentSetNumber + 1)"
        }

        let isLastSet = currentSetNumber >= max(exercise.numberOfSets, 1)
        if isLastSet && currentExerciseIndex == exercises.count - 1 {
            return "Finish Timer"
        } else if isLastSet {
            return "Complete Exercise"
        } else {
            return "Complete Set \(currentSetNumber)"
        }
    }

    // MARK: - Session Navigation

    private func handlePrimaryAction(for exercise: TimerExerciseItem) {
        if phase == .rest {
            finishRest(for: exercise)
        } else {
            completeSet(for: exercise)
        }
    }

    private func completeSet(for exercise: TimerExerciseItem) {
        provideImpactFeedback()

        remainingRestSeconds = max(exercise.restSeconds, 0)
        phase = .rest
        restCountdownID = UUID()
    }

    private func finishRest(for exercise: TimerExerciseItem) {
        if currentSetNumber >= max(exercise.numberOfSets, 1) {
            moveToNextExerciseOrFinish()
        } else {
            startNextSet()
        }
    }

    private func startNextSet() {
        currentSetNumber += 1
        phase = .exerciseSet
        remainingRestSeconds = 0
        restCountdownID = UUID()
        provideImpactFeedback()
    }

    private func goBackOneStep() {
        let wasResting = phase == .rest

        phase = .exerciseSet
        remainingRestSeconds = 0
        restCountdownID = UUID()

        if wasResting {
            provideImpactFeedback()
            return
        }

        if currentSetNumber > 1 {
            currentSetNumber -= 1
        } else if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSetNumber = max(exercises[currentExerciseIndex].numberOfSets, 1)
        }

        provideImpactFeedback()
    }

    private func moveToNextExerciseOrFinish() {
        if currentExerciseIndex == exercises.count - 1 {
            isFinished = true
            provideSuccessFeedback()
        } else {
            currentExerciseIndex += 1
            currentSetNumber = 1
            phase = .exerciseSet
            remainingRestSeconds = 0
            restCountdownID = UUID()
        }
    }

    private func resetTimer() {
        currentExerciseIndex = 0
        currentSetNumber = 1
        phase = .exerciseSet
        remainingRestSeconds = 0
        isFinished = false
        restCountdownID = UUID()
    }

    private func returnToLastSet() {
        isFinished = false
        phase = .exerciseSet
        remainingRestSeconds = 0
        restCountdownID = UUID()
        provideImpactFeedback()
    }

    // MARK: - Rest Countdown

    private func runRestCountdown() async {
        guard phase == .rest else { return }

        while remainingRestSeconds > 0 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }

            guard !Task.isCancelled, phase == .rest else { return }
            remainingRestSeconds -= 1

            if soundEnabled,
               countdownBeepsEnabled,
               remainingRestSeconds > 0,
               remainingRestSeconds <= 3 {
                WorkoutSoundPlayer.shared.playCountdownTick()
            }
        }

        guard phase == .rest else { return }

        if soundEnabled {
            WorkoutSoundPlayer.shared.playRestComplete()
        }
        provideSuccessFeedback()

        if autoStartNextSet, let currentExercise {
            finishRest(for: currentExercise)
        }
    }

    // MARK: - Settings and Feedback

    private func applyScreenAwakeSetting() {
        UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
            ? true
            : previousIdleTimerDisabled
    }

    private func provideImpactFeedback() {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func provideSuccessFeedback() {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - Display Text

    private func restDestinationDescription(for exercise: TimerExerciseItem) -> String {
        if currentSetNumber < max(exercise.numberOfSets, 1) {
            return "Before set \(currentSetNumber + 1) of \(max(exercise.numberOfSets, 1))"
        }

        if let nextExercise {
            return "Before \(nextExercise.exerciseName)"
        }

        return "Final rest before finishing"
    }
}
