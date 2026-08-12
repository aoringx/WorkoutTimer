//
//  WorkoutRunnerView.swift
//  WorkoutTimer
//

import SwiftUI
import UIKit

struct WorkoutRunnerView: View {
    private enum RunPhase {
        case warmUp
        case exerciseSet
        case rest
        case coolDown
    }

    private struct UpNextContent {
        let title: String
        let tint: Color
    }

    // MARK: - Dependencies and Settings

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
    @State private var isExitConfirmationPresented = false
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

    private var currentSetIndex: Int {
        let earlierSetCount = exercises.prefix(currentExerciseIndex).reduce(0) {
            $0 + max($1.numberOfSets, 1)
        }
        return earlierSetCount + max(currentSetNumber - 1, 0)
    }

    private var requiresExitConfirmation: Bool {
        !exercises.isEmpty && !isFinished && phase != .warmUp
    }

    private var currentExerciseTint: Color {
        guard let currentExercise else {
            return AppTheme.brand
        }
        return currentExercise.exerciseCategory.themeTint
    }

    private var phaseTint: Color {
        if isFinished {
            return AppTheme.success
        }

        return switch phase {
        case .warmUp:
            AppTheme.energy
        case .exerciseSet:
            currentExerciseTint
        case .rest:
            AppTheme.rest
        case .coolDown:
            AppTheme.success
        }
    }

    // MARK: - View

    var body: some View {
        ZStack {
            AppBackdrop(tint: phaseTint)

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
        }
        .navigationTitle(timer.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(requiresExitConfirmation)
        .toolbar {
            if requiresExitConfirmation {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isExitConfirmationPresented = true
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(phaseTint)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Exit workout")
                }
            }
        }
        .alert(
            "Exit Workout?",
            isPresented: $isExitConfirmationPresented
        ) {
            Button("Keep Going", role: .cancel) { }
            Button("Exit Workout", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your current workout progress will be lost.")
        }
        .tint(phaseTint)
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
                    RestCountdownNotification.cancel()
                }
                synchronizeRestCountdown()
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = previousIdleTimerDisabled
            RestCountdownNotification.cancel()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Exercises",
            systemImage: "list.bullet",
            description: Text("Add exercises to this workout from Manage Workouts.")
        )
    }

    private var warmUpScreen: some View {
        workoutPhaseScreen(
            title: "Warm-Up",
            subtitle: "Prepare your body before starting \(timer.name).",
            systemImage: "flame.fill",
            tint: AppTheme.energy,
            steps: [
                "Move gently for 3–5 minutes to raise your heart rate.",
                "Mobilize your wrists, shoulders, hips, and ankles.",
                "Practice the first exercise with an easy range of motion."
            ],
            primaryButtonTitle: "Start Workout",
            primarySystemImage: "play.fill",
            primaryAction: startWorkout
        )
    }

    private var coolDownScreen: some View {
        workoutPhaseScreen(
            title: "Cool-Down",
            subtitle: "Bring your breathing and heart rate down gradually.",
            systemImage: "leaf.fill",
            tint: AppTheme.success,
            steps: [
                "Walk or move slowly until your breathing settles.",
                "Gently stretch the muscles you trained.",
                "Take a moment to breathe, relax, and hydrate."
            ],
            primaryButtonTitle: "Complete Workout",
            primarySystemImage: "checkmark",
            primaryAction: completeCoolDown,
            secondaryButtonTitle: "Back to Final Rest",
            secondaryAction: returnToFinalRest
        )
    }

    private func workoutPhaseScreen(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        steps: [String],
        primaryButtonTitle: String,
        primarySystemImage: String,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        ScrollView {
            WorkoutPhaseCard(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                tint: tint,
                steps: steps
            )
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            WorkoutControlBar(tint: tint) {
                VStack(spacing: 10) {
                    if let secondaryButtonTitle, let secondaryAction {
                        Button(action: secondaryAction) {
                            Label(
                                secondaryButtonTitle,
                                systemImage: "arrow.uturn.backward"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }

                    Button(action: primaryAction) {
                        Label(
                            primaryButtonTitle,
                            systemImage: primarySystemImage
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .tint(tint)
    }

    private func exerciseScreen(_ exercise: TimerExerciseItem) -> some View {
        let accent = phase == .rest
            ? AppTheme.rest
            : exercise.exerciseCategory.themeTint

        return ScrollView {
            VStack(spacing: 12) {
                WorkoutProgressSection(
                    currentExerciseNumber: currentExerciseIndex + 1,
                    exerciseCount: exercises.count,
                    currentSetNumber: currentSetNumber,
                    exerciseSetCount: max(exercise.numberOfSets, 1),
                    completedSetCount: completedSetCount,
                    totalSetCount: totalSetCount,
                    exerciseNames: exercises.map(\.exerciseName),
                    currentExerciseIndex: currentExerciseIndex,
                    currentSetIndex: currentSetIndex,
                    tint: accent,
                    selectionAction: jumpToSet
                )

                if phase == .exerciseSet {
                    WorkoutSetCard(
                        exercise: exercise,
                        currentSetNumber: currentSetNumber
                    )
                } else {
                    WorkoutRestCard(
                        exercise: exercise,
                        remainingRestSeconds: remainingRestSeconds,
                        destinationDescription: restDestinationDescription(for: exercise)
                    )
                }

            }
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            WorkoutControlBar(tint: accent) {
                VStack(spacing: 8) {
                    if let upNext = upNextContent(for: exercise) {
                        WorkoutUpNextCard(
                            title: upNext.title,
                            tint: upNext.tint
                        )
                    }

                    Group {
                        if dynamicTypeSize.isAccessibilitySize {
                            VStack(spacing: 8) {
                                if canGoBack {
                                    previousStepButton
                                }

                                primaryActionButton(for: exercise)
                            }
                        } else {
                            HStack(spacing: 8) {
                                if canGoBack {
                                    previousStepButton
                                }

                                primaryActionButton(for: exercise)
                            }
                        }
                    }
                }
            }
        }
        .tint(accent)
    }

    private var completedState: some View {
        VStack {
            Spacer(minLength: 24)

            VStack(spacing: 20) {
                Image(systemName: "checkmark")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.success, AppTheme.electricBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                    )
                    .shadow(color: AppTheme.success.opacity(0.24), radius: 16, y: 8)
                    .accessibilityHidden(true)

                Text("Workout Complete")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Warm-up, workout, and cool-down complete.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 520)
            .padding(28)
            .background(
                AppTheme.success.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .appSurface(tint: AppTheme.success, cornerRadius: 28)
            .padding(.horizontal, 16)

            Spacer(minLength: 24)
        }
        .safeAreaInset(edge: .bottom) {
            WorkoutControlBar(tint: AppTheme.success) {
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        returnToCoolDown()
                    } label: {
                        Label(
                            "Back to Cool-Down",
                            systemImage: "arrow.uturn.backward"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
        .tint(AppTheme.success)
    }

    // MARK: - Controls

    private var canGoBack: Bool {
        phase == .exerciseSet || phase == .rest
    }

    private var previousButtonTitle: String {
        if phase == .rest {
            return "Back to Set \(currentSetNumber)"
        } else if currentExerciseIndex == 0 {
            return currentSetNumber == 1
                ? "Back to Warm-Up"
                : "Previous Rest"
        } else {
            return "Previous Rest"
        }
    }

    private var previousStepButton: some View {
        Button {
            goBackOneStep()
        } label: {
            Label(
                previousButtonTitle,
                systemImage: "arrow.uturn.backward"
            )
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }

    private func primaryActionButton(
        for exercise: TimerExerciseItem
    ) -> some View {
        Button {
            handlePrimaryAction(for: exercise)
        } label: {
            Label(
                primaryButtonTitle(for: exercise),
                systemImage: primaryButtonSystemImage(for: exercise)
            )
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
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

    private func primaryButtonSystemImage(
        for exercise: TimerExerciseItem
    ) -> String {
        if phase == .rest {
            return remainingRestSeconds > 0
                ? "forward.end.fill"
                : "play.fill"
        }

        return currentSetNumber >= max(exercise.numberOfSets, 1)
            ? "checkmark.circle.fill"
            : "checkmark"
    }

    // MARK: - Session Navigation

    private func startWorkout() {
        phase = .exerciseSet
        provideImpactFeedback()
    }

    private func jumpToSet(at index: Int) {
        guard (0..<totalSetCount).contains(index), index != currentSetIndex else {
            return
        }

        var remainingIndex = index

        for (exerciseIndex, exercise) in exercises.enumerated() {
            let setCount = max(exercise.numberOfSets, 1)
            guard remainingIndex >= setCount else {
                RestCountdownNotification.cancel()
                currentExerciseIndex = exerciseIndex
                currentSetNumber = remainingIndex + 1
                phase = .exerciseSet
                remainingRestSeconds = 0
                restEndDate = nil
                restCountdownID = UUID()
                provideImpactFeedback()
                return
            }

            remainingIndex -= setCount
        }
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
        beginRest(for: exercise)
    }

    private func beginRest(
        for exercise: TimerExerciseItem,
        isRevisiting: Bool = false
    ) {
        RestCountdownNotification.cancel()
        let restSeconds = max(exercise.restSeconds, 0)
        // Keep a revisited zero-length rest visible until the user advances.
        let endDate = restSeconds == 0 && isRevisiting
            ? nil
            : Date().addingTimeInterval(TimeInterval(restSeconds))

        remainingRestSeconds = restSeconds
        restEndDate = endDate
        phase = .rest
        restCountdownID = UUID()

        if let endDate {
            RestCountdownNotification.schedule(
                endDate: endDate,
                message: restCompletionNotificationMessage(for: exercise),
                soundEnabled: soundEnabled
            )
        }
    }

    private func finishRest(for exercise: TimerExerciseItem) {
        RestCountdownNotification.cancel()
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
        RestCountdownNotification.cancel()
        remainingRestSeconds = 0
        restEndDate = nil
        restCountdownID = UUID()

        if phase == .rest {
            phase = .exerciseSet
        } else if currentSetNumber > 1 {
            currentSetNumber -= 1
            beginRest(
                for: exercises[currentExerciseIndex],
                isRevisiting: true
            )
        } else if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSetNumber = max(exercises[currentExerciseIndex].numberOfSets, 1)
            beginRest(
                for: exercises[currentExerciseIndex],
                isRevisiting: true
            )
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

    private func returnToFinalRest() {
        guard let finalExerciseIndex = exercises.indices.last else { return }

        isFinished = false
        currentExerciseIndex = finalExerciseIndex
        currentSetNumber = max(exercises[finalExerciseIndex].numberOfSets, 1)
        beginRest(
            for: exercises[finalExerciseIndex],
            isRevisiting: true
        )
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
            RestCountdownNotification.cancel()

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

    private func upNextContent(
        for exercise: TimerExerciseItem
    ) -> UpNextContent? {
        let setCount = max(exercise.numberOfSets, 1)

        if phase == .exerciseSet {
            guard currentSetNumber >= setCount, let nextExercise else {
                return nil
            }

            return UpNextContent(
                title: nextExercise.exerciseName,
                tint: tint(for: nextExercise)
            )
        }

        guard phase == .rest, currentSetNumber >= setCount else {
            return nil
        }

        if let nextExercise {
            return UpNextContent(
                title: nextExercise.exerciseName,
                tint: tint(for: nextExercise)
            )
        }

        return UpNextContent(
            title: "Cool-Down",
            tint: AppTheme.success
        )
    }

    private func tint(for exercise: TimerExerciseItem) -> Color {
        exercise.exerciseCategory.themeTint
    }

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
