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
    @State private var notes: String
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
        _notes = State(initialValue: exercise?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    Picker("Type", selection: $category) {
                        ForEach(ExerciseCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                }

                Section("Workout Settings") {
                    Stepper("Sets: \(numberOfSets)", value: $numberOfSets, in: 1...20)
                    Stepper(
                        "Reps/Seconds: \(numberOfReps)",
                        value: $numberOfReps,
                        in: 1...100
                    )
                    Stepper(
                        "Rest Time: \(restTimeDescription)",
                        value: $restSeconds,
                        in: 0...600,
                        step: 30
                    )
                }

                Section("Notes") {
                    TextField(
                        "Instructions, equipment, or other details",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(3...8)
                }

                if isDuplicate {
                    Section {
                        Label(
                            "An exercise with this name already exists.",
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.orange)
                    }
                }
            }
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
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exercise {
            exercise.name = trimmedName
            exercise.exerciseCategory = category
            exercise.numberOfSets = numberOfSets
            exercise.numberOfReps = numberOfReps
            exercise.restSeconds = restSeconds
            exercise.notes = trimmedNotes
            exercise.updatedAt = Date()
        } else {
            modelContext.insert(
                ExerciseItem(
                    name: trimmedName,
                    category: category,
                    notes: trimmedNotes,
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
