//
//  TimerRunnerView.swift
//  WorkoutTimer
//

import SwiftUI
import UIKit

struct TimerRunnerView: View {
    private enum RunPhase {
        case warmUp
        case exerciseSet
        case rest
        case coolDown
    }

    // MARK: - Dependencies and Settings

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

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
    @State private var phase = RunPhase.warmUp
    @State private var remainingRestSeconds = 0
    @State private var restEndDate: Date?
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
            } else {
                switch phase {
                case .warmUp:
                    warmUpScreen
                case .exerciseSet, .rest:
                    if let currentExercise {
                        exerciseScreen(currentExercise)
                    }
                case .coolDown:
                    coolDownScreen
                }
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
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if phase != .rest || restEndDate == nil {
                    RestTimerNotification.cancel()
                }
                synchronizeRestCountdown()
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = previousIdleTimerDisabled
            RestTimerNotification.cancel()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Exercises",
            systemImage: "list.bullet",
            description: Text("Add exercises to this timer from Manage Timers.")
        )
    }

    private var warmUpScreen: some View {
        routinePhaseScreen(
            title: "Warm-Up",
            subtitle: "Prepare your body before starting \(timer.name).",
            systemImage: "flame.fill",
            tint: .orange,
            steps: [
                "Move gently for 3–5 minutes to raise your heart rate.",
                "Mobilize your wrists, shoulders, hips, and ankles.",
                "Practice the first exercise with an easy range of motion."
            ],
            primaryButtonTitle: "Start Workout",
            primaryAction: startWorkout
        )
    }

    private var coolDownScreen: some View {
        routinePhaseScreen(
            title: "Cool-Down",
            subtitle: "Bring your breathing and heart rate down gradually.",
            systemImage: "leaf.fill",
            tint: .green,
            steps: [
                "Walk or move slowly until your breathing settles.",
                "Gently stretch the muscles you trained.",
                "Take a moment to breathe, relax, and hydrate."
            ],
            primaryButtonTitle: "Complete Workout",
            primaryAction: completeCoolDown,
            secondaryButtonTitle: "Back to Last Set",
            secondaryAction: returnToLastSet
        )
    }

    private func routinePhaseScreen(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        steps: [String],
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        ScrollView {
            TimerRoutinePhaseCard(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                tint: tint,
                steps: steps
            )
            .padding()
            .padding(.bottom, 72)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if let secondaryButtonTitle, let secondaryAction {
                    Button(
                        secondaryButtonTitle,
                        systemImage: "arrow.uturn.backward",
                        action: secondaryAction
                    )
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button(primaryButtonTitle, action: primaryAction)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding()
            .background(.bar)
        }
        .tint(tint)
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
                    totalSetCount: totalSetCount,
                    exerciseNames: exercises.map(\.exerciseName),
                    currentExerciseIndex: currentExerciseIndex,
                    selectionAction: jumpToExercise
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

            Text("Warm-up, workout, and cool-down complete.")
                .foregroundStyle(.secondary)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)

            Button("Back to Cool-Down", systemImage: "arrow.uturn.backward") {
                returnToCoolDown()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }

    // MARK: - Controls

    private var canGoBack: Bool {
        phase == .exerciseSet || phase == .rest
    }

    private var previousButtonTitle: String {
        if phase == .rest {
            return "Back to Set \(currentSetNumber)"
        } else if currentSetNumber > 1 {
            return "Previous Set"
        } else if currentExerciseIndex == 0 {
            return "Back to Warm-Up"
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
                    ? "Start Cool-Down"
                    : "Next Exercise"
            }

            return "Start Set \(currentSetNumber + 1)"
        }

        let isLastSet = currentSetNumber >= max(exercise.numberOfSets, 1)
        if isLastSet && currentExerciseIndex == exercises.count - 1 {
            return "Complete Final Set"
        } else if isLastSet {
            return "Complete Exercise"
        } else {
            return "Complete Set \(currentSetNumber)"
        }
    }

    // MARK: - Session Navigation

    private func startWorkout() {
        phase = .exerciseSet
        provideImpactFeedback()
    }

    private func jumpToExercise(at index: Int) {
        guard exercises.indices.contains(index), index != currentExerciseIndex else {
            return
        }

        RestTimerNotification.cancel()
        currentExerciseIndex = index
        currentSetNumber = 1
        phase = .exerciseSet
        remainingRestSeconds = 0
        restEndDate = nil
        restCountdownID = UUID()
        provideImpactFeedback()
    }

    private func handlePrimaryAction(for exercise: TimerExerciseItem) {
        if phase == .rest {
            finishRest(for: exercise)
        } else {
            completeSet(for: exercise)
        }
    }

    private func completeSet(for exercise: TimerExerciseItem) {
        provideImpactFeedback()

        let restSeconds = max(exercise.restSeconds, 0)
        let endDate = Date().addingTimeInterval(TimeInterval(restSeconds))

        remainingRestSeconds = restSeconds
        restEndDate = endDate
        phase = .rest
        restCountdownID = UUID()

        RestTimerNotification.schedule(
            endDate: endDate,
            message: restCompletionNotificationMessage(for: exercise),
            soundEnabled: soundEnabled
        )
    }

    private func finishRest(for exercise: TimerExerciseItem) {
        RestTimerNotification.cancel()
        advanceAfterRest(for: exercise)
    }

    private func advanceAfterRest(for exercise: TimerExerciseItem) {
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
        restEndDate = nil
        restCountdownID = UUID()
        provideImpactFeedback()
    }

    private func goBackOneStep() {
        let wasResting = phase == .rest

        RestTimerNotification.cancel()
        phase = .exerciseSet
        remainingRestSeconds = 0
        restEndDate = nil
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
        } else {
            phase = .warmUp
        }

        provideImpactFeedback()
    }

    private func moveToNextExerciseOrFinish() {
        if currentExerciseIndex == exercises.count - 1 {
            phase = .coolDown
            remainingRestSeconds = 0
            restEndDate = nil
            restCountdownID = UUID()

            if scenePhase == .active {
                provideImpactFeedback()
            }
        } else {
            currentExerciseIndex += 1
            currentSetNumber = 1
            phase = .exerciseSet
            remainingRestSeconds = 0
            restEndDate = nil
            restCountdownID = UUID()
        }
    }

    private func completeCoolDown() {
        isFinished = true
        provideSuccessFeedback()
    }

    private func returnToLastSet() {
        isFinished = false
        phase = .exerciseSet
        remainingRestSeconds = 0
        restEndDate = nil
        restCountdownID = UUID()
        provideImpactFeedback()
    }

    private func returnToCoolDown() {
        isFinished = false
        phase = .coolDown
        provideImpactFeedback()
    }

    // MARK: - Rest Countdown

    private func runRestCountdown() async {
        guard phase == .rest, let endDate = restEndDate else { return }

        while true {
            guard phase == .rest, restEndDate == endDate else { return }

            let updatedRemainingSeconds = secondsRemaining(until: endDate)
            if updatedRemainingSeconds != remainingRestSeconds {
                remainingRestSeconds = updatedRemainingSeconds

                if soundEnabled,
                   countdownBeepsEnabled,
                   updatedRemainingSeconds > 0,
                   updatedRemainingSeconds <= 3 {
                    WorkoutSoundPlayer.shared.playCountdownTick()
                }
            }

            if updatedRemainingSeconds == 0 {
                completeRestCountdown(endingAt: endDate)
                return
            }

            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }
        }
    }

    private func synchronizeRestCountdown() {
        guard phase == .rest, let endDate = restEndDate else { return }

        remainingRestSeconds = secondsRemaining(until: endDate)
        if remainingRestSeconds == 0 {
            completeRestCountdown(endingAt: endDate)
        }
    }

    private func completeRestCountdown(endingAt endDate: Date) {
        guard phase == .rest, restEndDate == endDate else { return }

        remainingRestSeconds = 0
        restEndDate = nil

        if scenePhase == .active {
            RestTimerNotification.cancel()

            if soundEnabled {
                WorkoutSoundPlayer.shared.playRestComplete()
            }
            provideSuccessFeedback()
        }

        if autoStartNextSet, let currentExercise {
            advanceAfterRest(for: currentExercise)
        }
    }

    private func secondsRemaining(until endDate: Date) -> Int {
        max(Int(ceil(endDate.timeIntervalSinceNow)), 0)
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

        return "Final rest before cool-down"
    }

    private func restCompletionNotificationMessage(
        for exercise: TimerExerciseItem
    ) -> String {
        if currentSetNumber < max(exercise.numberOfSets, 1) {
            return "Ready for the next set of \(exercise.exerciseName)."
        }

        if let nextExercise {
            return "Ready to start \(nextExercise.exerciseName)."
        }

        return "Your workout is ready for the cool-down."
    }
}
