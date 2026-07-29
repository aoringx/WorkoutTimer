//
//  CreateWorkoutView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
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

    private var totalSetCount: Int {
        selectedExercises.reduce(0) { $0 + $1.numberOfSets }
    }

    var body: some View {
        content
        .navigationTitle("Create Workout")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.brand)
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

    @ViewBuilder
    private var content: some View {
        if selectedExercises.isEmpty {
            emptyState
        } else {
            timerList
        }
    }

    private var emptyState: some View {
        ZStack {
            AppBackdrop(tint: AppTheme.energy)

            ContentUnavailableView {
                Label("No Exercises Added", systemImage: "list.bullet")
            } description: {
                Text("Add exercises from your library to build this workout.")
            } actions: {
                Button("Add Exercises", systemImage: "plus") {
                    isExercisePickerPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var timerList: some View {
        List {
            timerDetailsSection
            exercisesSection
        }
        .listStyle(.insetGrouped)
        .appListBackground(tint: AppTheme.brand)
    }

    private var timerDetailsSection: some View {
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

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    MetricChip(
                        text: "\(selectedExercises.count) exercises",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                    MetricChip(
                        text: "\(totalSetCount) sets",
                        systemImage: "square.stack.3d.up"
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    MetricChip(
                        text: "\(selectedExercises.count) exercises",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                    MetricChip(
                        text: "\(totalSetCount) sets",
                        systemImage: "square.stack.3d.up"
                    )
                }
            }
        }
    }

    private var exercisesSection: some View {
        Section {
            ForEach(selectedExercises) { exercise in
                WorkoutExerciseRow(exercise: exercise)
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

private struct WorkoutExerciseRow: View {
    let exercise: ExerciseItem

    var body: some View {
        ExerciseSummaryContent(
            name: exercise.name,
            category: exercise.exerciseCategory.rawValue,
            sets: exercise.numberOfSets,
            reps: exercise.numberOfReps,
            restSeconds: exercise.restSeconds
        )
    }
}
