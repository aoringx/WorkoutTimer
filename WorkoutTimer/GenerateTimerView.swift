//
//  GenerateTimerView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct GenerateTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedTimers: [WorkoutTimerItem]

    @State private var selectedExercises: [ExerciseItem] = []
    @State private var isExercisePickerPresented = true
    @State private var timerName = ""
    @State private var saveError: Error?

    private var trimmedTimerName: String {
        timerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicateTimerName: Bool {
        savedTimers.contains { timer in
            timer.name.normalizedForComparison
                == trimmedTimerName.normalizedForComparison
        }
    }

    private var canSave: Bool {
        !selectedExercises.isEmpty
            && !trimmedTimerName.isEmpty
            && !isDuplicateTimerName
    }

    var body: some View {
        content
        .navigationTitle("Generate New Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            timerToolbar
        }
        .fullScreenCover(isPresented: $isExercisePickerPresented) {
            ExercisePickerView(
                excludedExerciseIDs: Set(selectedExercises.map(\.id))
            ) { exercises in
                selectedExercises.append(contentsOf: exercises)
            }
        }
        .alert(
            "Couldn’t Save Timer",
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

    @ViewBuilder
    private var content: some View {
        if selectedExercises.isEmpty {
            emptyState
        } else {
            timerList
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Exercises Added", systemImage: "list.bullet")
        } description: {
            Text("Add exercises from your library to build this timer.")
        } actions: {
            Button("Add Exercises", systemImage: "plus") {
                isExercisePickerPresented = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var timerList: some View {
        List {
            timerDetailsSection
            exercisesSection
        }
        .listStyle(.insetGrouped)
    }

    private var timerDetailsSection: some View {
        Section("Timer") {
            TextField("Timer Name", text: $timerName)
                .textInputAutocapitalization(.words)

            if isDuplicateTimerName {
                Label(
                    "A timer with this name already exists.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
    }

    private var exercisesSection: some View {
        Section {
            ForEach(selectedExercises) { exercise in
                TimerExerciseRow(exercise: exercise)
            }
            .onDelete(perform: removeExercises)
            .onMove(perform: moveExercises)

            Button("Add Exercises") {
                isExercisePickerPresented = true
            }
        } header: {
            Text("Exercises")
        } footer: {
            Text("Use Edit to drag exercises into the order they should run.")
        }
    }

    @ToolbarContentBuilder
    private var timerToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if !selectedExercises.isEmpty {
                EditButton()
            }

            Button("Save") {
                saveTimer()
            }
            .disabled(!canSave)
        }
    }

    private func removeExercises(at offsets: IndexSet) {
        withAnimation {
            selectedExercises.remove(atOffsets: offsets)
        }
    }

    private func moveExercises(from source: IndexSet, to destination: Int) {
        withAnimation {
            selectedExercises.move(fromOffsets: source, toOffset: destination)
        }
    }

    private func saveTimer() {
        guard canSave else { return }

        let timerExercises = selectedExercises.enumerated().map { position, exercise in
            TimerExerciseItem(position: position, exercise: exercise)
        }
        let timer = WorkoutTimerItem(
            name: trimmedTimerName,
            manualSortOrder: nextManualSortOrder,
            exercises: timerExercises
        )

        modelContext.insert(timer)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            saveError = error
        }
    }

    private var nextManualSortOrder: Int {
        (savedTimers.map(\.manualSortOrder).max() ?? -1) + 1
    }
}

private struct TimerExerciseRow: View {
    let exercise: ExerciseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exercise.name)
                    .font(.headline)

                Spacer()

                Text(exercise.exerciseCategory.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(
                "\(exercise.numberOfSets) sets × \(exercise.numberOfReps) reps • "
                    + "\(exercise.restSeconds) sec rest"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
