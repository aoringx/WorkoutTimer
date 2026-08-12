//
//  EditWorkoutView.swift
//  WorkoutTimer
//

import SwiftData
import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedTimers: [WorkoutTimerItem]

    let timer: WorkoutTimerItem

    @State private var timerName: String
    @State private var exercises: [TimerExerciseDraft]
    @State private var isExercisePickerPresented = false
    @State private var saveError: Error?

    init(timer: WorkoutTimerItem) {
        self.timer = timer
        _timerName = State(initialValue: timer.name)
        _exercises = State(
            initialValue: timer.orderedExercises.map { exercise in
                TimerExerciseDraft(exercise)
            }
        )
    }

    private var trimmedTimerName: String {
        timerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicateTimerName: Bool {
        savedTimers.contains { savedTimer in
            savedTimer.id != timer.id
                && savedTimer.name.normalizedForComparison
                    == trimmedTimerName.normalizedForComparison
        }
    }

    private var canSave: Bool {
        !exercises.isEmpty
            && !trimmedTimerName.isEmpty
            && !isDuplicateTimerName
    }

    private var totalSetCount: Int {
        exercises.reduce(0) { $0 + $1.numberOfSets }
    }

    var body: some View {
        List {
            Section("Workout Details") {
                VStack(alignment: .leading, spacing: 10) {
                    SettingsRowLabel(
                        title: "Workout Name",
                        systemImage: "textformat",
                        tint: AppTheme.brand
                    )

                    TextField("Name your workout", text: $timerName)
                        .font(.headline)
                        .textInputAutocapitalization(.words)
                }

                if isDuplicateTimerName {
                    Label(
                        "A workout with this name already exists.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(AppTheme.energy)
                }

                WrappingHStack(horizontalSpacing: 8, verticalSpacing: 8) {
                    MetricChip(
                        text: "\(exercises.count) exercises",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                    MetricChip(
                        text: "\(totalSetCount) sets",
                        systemImage: "square.stack.3d.up"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Section {
                ForEach(exercises) { exercise in
                    TimerExerciseDraftRow(exercise: exercise)
                }
                .onDelete(perform: removeExercises)
                .onMove(perform: moveExercises)

                Button {
                    isExercisePickerPresented = true
                } label: {
                    Label("Add Exercises", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.brand)
                }
            } header: {
                Text("Exercise Order")
            } footer: {
                Text("Use Edit to remove or reorder exercises.")
            }
        }
        .listStyle(.insetGrouped)
        .appListBackground(tint: AppTheme.brand)
        .tint(AppTheme.brand)
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !exercises.isEmpty {
                    EditButton()
                }

                Button("Save") {
                    saveChanges()
                }
                .disabled(!canSave)
            }
        }
        .fullScreenCover(isPresented: $isExercisePickerPresented) {
            ExercisePickerView { selectedExercises in
                exercises.append(
                    contentsOf: selectedExercises.map { exercise in
                        TimerExerciseDraft(exercise)
                    }
                )
            }
        }
        .alert(
            "Couldn’t Save Workout",
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

    private func removeExercises(at offsets: IndexSet) {
        withAnimation {
            exercises.remove(atOffsets: offsets)
        }
    }

    private func moveExercises(from source: IndexSet, to destination: Int) {
        withAnimation {
            exercises.move(fromOffsets: source, toOffset: destination)
        }
    }

    private func saveChanges() {
        guard canSave else { return }

        let oldExercises = timer.exercises
        let updatedExercises = exercises.enumerated().map { position, exercise in
            exercise.makeStoredExercise(position: position)
        }

        timer.name = trimmedTimerName
        timer.updatedAt = Date()
        timer.exercises = updatedExercises

        for exercise in updatedExercises {
            exercise.timer = timer
        }

        for exercise in oldExercises {
            modelContext.delete(exercise)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            saveError = error
        }
    }
}

private struct TimerExerciseDraft: Identifiable {
    let id: UUID
    let exerciseName: String
    let category: ExerciseCategory
    let numberOfSets: Int
    let numberOfReps: Int
    let restSeconds: Int

    init(_ exercise: TimerExerciseItem) {
        id = exercise.id
        exerciseName = exercise.exerciseName
        category = exercise.exerciseCategory
        numberOfSets = exercise.numberOfSets
        numberOfReps = exercise.numberOfReps
        restSeconds = exercise.restSeconds
    }

    init(_ exercise: ExerciseItem) {
        id = UUID()
        exerciseName = exercise.name
        category = exercise.exerciseCategory
        numberOfSets = exercise.numberOfSets
        numberOfReps = exercise.numberOfReps
        restSeconds = exercise.restSeconds
    }

    func makeStoredExercise(position: Int) -> TimerExerciseItem {
        TimerExerciseItem(
            position: position,
            exerciseName: exerciseName,
            category: category,
            numberOfSets: numberOfSets,
            numberOfReps: numberOfReps,
            restSeconds: restSeconds
        )
    }
}

private struct TimerExerciseDraftRow: View {
    let exercise: TimerExerciseDraft

    var body: some View {
        ExerciseSummaryContent(
            name: exercise.exerciseName,
            category: exercise.category,
            sets: exercise.numberOfSets,
            reps: exercise.numberOfReps,
            restSeconds: exercise.restSeconds
        )
    }
}
