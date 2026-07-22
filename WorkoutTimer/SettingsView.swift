//
//  SettingsView.swift
//  WorkoutTimer
//

import SwiftUI

struct SettingsView: View {
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

    @AppStorage(AppSettingKey.defaultSets)
    private var defaultSets = AppSettingDefault.sets

    @AppStorage(AppSettingKey.defaultReps)
    private var defaultReps = AppSettingDefault.reps

    @AppStorage(AppSettingKey.defaultRestSeconds)
    private var defaultRestSeconds = AppSettingDefault.restSeconds

    @State private var isResetConfirmationPresented = false

    var body: some View {
        Form {
            Section {
                Toggle("Sound Effects", isOn: $soundEnabled)

                Toggle("Countdown Beeps", isOn: $countdownBeepsEnabled)
                    .disabled(!soundEnabled)

                Toggle("Haptic Feedback", isOn: $hapticsEnabled)
            } header: {
                Text("Audio & Feedback")
            } footer: {
                Text("Countdown beeps play during the final three seconds of rest.")
            }

            Section {
                Toggle("Automatically Start Next Set", isOn: $autoStartNextSet)
                Toggle("Keep Screen Awake During Timers", isOn: $keepScreenAwake)
            } header: {
                Text("Timer Behavior")
            } footer: {
                Text(
                    "Auto-start advances to the next set or exercise as soon as rest ends."
                )
            }

            Section {
                Stepper("Sets: \(defaultSets)", value: $defaultSets, in: 1...20)
                Stepper(
                    "Reps/Seconds: \(defaultReps)",
                    value: $defaultReps,
                    in: 1...100
                )
                Stepper(
                    "Rest Time: \(restTimeDescription)",
                    value: $defaultRestSeconds,
                    in: 0...600,
                    step: 5
                )
            } header: {
                Text("New Exercise Defaults")
            } footer: {
                Text("These values are prefilled when you add an exercise.")
            }

            Section {
                Button("Restore Default Settings", role: .destructive) {
                    isResetConfirmationPresented = true
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Restore Default Settings?",
            isPresented: $isResetConfirmationPresented
        ) {
            Button("Restore Defaults", role: .destructive) {
                restoreDefaults()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("All preferences on this page will be reset.")
        }
    }

    private var restTimeDescription: String {
        guard defaultRestSeconds > 0 else { return "None" }

        let minutes = defaultRestSeconds / 60
        let seconds = defaultRestSeconds % 60

        if minutes == 0 {
            return "\(seconds) sec"
        } else if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes) min \(seconds) sec"
        }
    }

    private func restoreDefaults() {
        soundEnabled = AppSettingDefault.soundEnabled
        countdownBeepsEnabled = AppSettingDefault.countdownBeepsEnabled
        hapticsEnabled = AppSettingDefault.hapticsEnabled
        autoStartNextSet = AppSettingDefault.autoStartNextSet
        keepScreenAwake = AppSettingDefault.keepScreenAwake
        defaultSets = AppSettingDefault.sets
        defaultReps = AppSettingDefault.reps
        defaultRestSeconds = AppSettingDefault.restSeconds
    }
}
