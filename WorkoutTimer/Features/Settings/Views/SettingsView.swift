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
                Toggle(isOn: $soundEnabled) {
                    SettingsRowLabel(
                        title: "Sound Effects",
                        systemImage: "speaker.wave.2.fill",
                        tint: AppTheme.electricBlue
                    )
                }

                Toggle(isOn: $countdownBeepsEnabled) {
                    SettingsRowLabel(
                        title: "Countdown Beeps",
                        systemImage: "metronome",
                        tint: AppTheme.energy
                    )
                }
                    .disabled(!soundEnabled)

                Toggle(isOn: $hapticsEnabled) {
                    SettingsRowLabel(
                        title: "Haptic Feedback",
                        systemImage: "waveform.path",
                        tint: AppTheme.brand
                    )
                }
            } header: {
                Text("Audio & Feedback")
            } footer: {
                Text("Countdown beeps play during the final three seconds of rest.")
            }

            Section {
                Toggle(isOn: $autoStartNextSet) {
                    SettingsRowLabel(
                        title: "Automatically Start Next Set",
                        systemImage: "forward.fill",
                        tint: AppTheme.success
                    )
                }

                Toggle(isOn: $keepScreenAwake) {
                    SettingsRowLabel(
                        title: "Keep Screen Awake During Workouts",
                        systemImage: "sun.max.fill",
                        tint: AppTheme.energy
                    )
                }
            } header: {
                Text("Workout Behavior")
            } footer: {
                Text(
                    "Auto-start advances to the next set or exercise as soon as rest ends."
                )
            }

            Section {
                Stepper(value: $defaultSets, in: 1...20) {
                    HStack {
                        SettingsRowLabel(
                            title: "Sets",
                            systemImage: "square.stack.3d.up",
                            tint: AppTheme.brand
                        )

                        Spacer()

                        Text("\(defaultSets)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(value: $defaultReps, in: 1...600) {
                    HStack {
                        SettingsRowLabel(
                            title: "Reps / Seconds",
                            systemImage: "repeat",
                            tint: AppTheme.electricBlue
                        )

                        Spacer()

                        Text("\(defaultReps)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Stepper(
                    value: $defaultRestSeconds,
                    in: 0...600,
                    step: 5
                ) {
                    HStack {
                        SettingsRowLabel(
                            title: "Rest Time",
                            systemImage: "timer",
                            tint: AppTheme.rest
                        )

                        Spacer()

                        Text(restTimeDescription)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            } header: {
                Text("New Exercise Defaults")
            } footer: {
                Text("These values are prefilled when you add an exercise.")
            }

            Section {
                Button(role: .destructive) {
                    isResetConfirmationPresented = true
                } label: {
                    SettingsRowLabel(
                        title: "Restore Default Settings",
                        systemImage: "arrow.counterclockwise",
                        tint: AppTheme.rest
                    )
                }
            }
        }
        .appListBackground(tint: AppTheme.electricBlue)
        .tint(AppTheme.brand)
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
