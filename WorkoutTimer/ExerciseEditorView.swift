//
//  ExerciseEditorView.swift
//  WorkoutTimer
//

import SwiftData
import SwiftUI

struct ExerciseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [ExerciseItem]

    let exercise: ExerciseItem?

    @State private var name: String
    @State private var category: ExerciseCategory
    @State private var numberOfSets: Int
    @State private var numberOfReps: Int
    @State private var restSeconds: Int
    @State private var saveError: Error?

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicate: Bool {
        exercises.contains { candidate in
            candidate.id != exercise?.id
                && candidate.name.normalizedForComparison
                    == trimmedName.normalizedForComparison
        }
    }

    init(
        exercise: ExerciseItem?,
        defaultSets: Int,
        defaultReps: Int,
        defaultRestSeconds: Int
    ) {
        self.exercise = exercise
        _name = State(initialValue: exercise?.name ?? "")
        _category = State(initialValue: exercise?.exerciseCategory ?? .push)
        _numberOfSets = State(initialValue: exercise?.numberOfSets ?? defaultSets)
        _numberOfReps = State(initialValue: exercise?.numberOfReps ?? defaultReps)
        _restSeconds = State(initialValue: exercise?.restSeconds ?? defaultRestSeconds)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    VStack(alignment: .leading, spacing: 10) {
                        SettingsRowLabel(
                            title: "Name",
                            systemImage: "textformat",
                            tint: category.themeTint
                        )

                        TextField("Exercise name", text: $name)
                            .font(.headline)
                    }
                    .textInputAutocapitalization(.words)

                    Picker(selection: $category) {
                        ForEach(ExerciseCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    } label: {
                        Text("Type")
                    }

                    if isDuplicate {
                        Label(
                            "An exercise with this name already exists.",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(AppTheme.energy)
                    }
                }

                Section("Workout Settings") {
                    Stepper(value: $numberOfSets, in: 1...20) {
                        HStack {
                            SettingsRowLabel(
                                title: "Sets",
                                systemImage: "square.stack.3d.up",
                                tint: AppTheme.brand
                            )

                            Spacer()

                            Text("\(numberOfSets)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }

                    Stepper(value: $numberOfReps, in: 1...100) {
                        HStack {
                            SettingsRowLabel(
                                title: "Reps / Seconds",
                                systemImage: "repeat",
                                tint: AppTheme.electricBlue
                            )

                            Spacer()

                            Text("\(numberOfReps)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }

                    Stepper(
                        value: $restSeconds,
                        in: 0...600,
                        step: 30
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
                }

            }
            .appListBackground(tint: category.themeTint)
            .tint(category.themeTint)
            .navigationTitle(exercise == nil ? "New Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(trimmedName.isEmpty || isDuplicate)
                }
            }
            .alert(
                "Couldn’t Save Exercise",
                isPresented: Binding(
                    get: { saveError != nil },
                    set: { if !$0 { saveError = nil } }
                ),
                presenting: saveError
            ) { _ in
                Button("OK", role: .cancel) { }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }

    private func save() {
        if let exercise {
            exercise.name = trimmedName
            exercise.exerciseCategory = category
            exercise.numberOfSets = numberOfSets
            exercise.numberOfReps = numberOfReps
            exercise.restSeconds = restSeconds
            exercise.updatedAt = Date()
        } else {
            modelContext.insert(
                ExerciseItem(
                    name: trimmedName,
                    category: category,
                    numberOfSets: numberOfSets,
                    numberOfReps: numberOfReps,
                    restSeconds: restSeconds
                )
            )
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            saveError = error
        }
    }

    private var restTimeDescription: String {
        guard restSeconds > 0 else { return "None" }

        let minutes = restSeconds / 60
        let seconds = restSeconds % 60

        if minutes == 0 {
            return "\(seconds) sec"
        } else if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes) min \(seconds) sec"
        }
    }
}
