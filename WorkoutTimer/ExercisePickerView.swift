//
//  ExercisePickerView.swift
//  WorkoutTimer
//

import SwiftData
import SwiftUI

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseItem.name) private var exercises: [ExerciseItem]

    let excludedExerciseIDs: Set<UUID>
    let excludedExerciseNames: Set<String>
    let onAdd: ([ExerciseItem]) -> Void

    @State private var selectedExerciseIDs: [UUID] = []
    @State private var searchText = ""

    init(
        excludedExerciseIDs: Set<UUID> = [],
        excludedExerciseNames: Set<String> = [],
        onAdd: @escaping ([ExerciseItem]) -> Void
    ) {
        self.excludedExerciseIDs = excludedExerciseIDs
        self.excludedExerciseNames = excludedExerciseNames
        self.onAdd = onAdd
    }

    private var visibleExercises: [ExerciseItem] {
        guard !searchText.isEmpty else { return exercises }

        return exercises.filter { exercise in
            exercise.name.localizedStandardContains(searchText)
                || exercise.exerciseCategories.contains { category in
                    category.rawValue.localizedStandardContains(searchText)
                }
        }
    }

    private var exercisesToAdd: [ExerciseItem] {
        let exercisesByID = Dictionary(
            uniqueKeysWithValues: exercises.map { ($0.id, $0) }
        )
        return selectedExerciseIDs.compactMap { exercisesByID[$0] }
    }

    var body: some View {
        NavigationStack {
            Group {
                if exercises.isEmpty {
                    ContentUnavailableView {
                        Label("Exercise Library Is Empty", systemImage: "books.vertical")
                    } description: {
                        Text("Create exercises before adding them to a workout.")
                    } actions: {
                        NavigationLink("Manage Exercises") {
                            ExercisesOptionsView()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if visibleExercises.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(visibleExercises) { exercise in
                        let isAlreadyAdded = excludedExerciseIDs.contains(exercise.id)
                            || excludedExerciseNames.contains(
                                exercise.name.normalizedForComparison
                            )
                        let selectionNumber = selectedExerciseIDs.firstIndex(of: exercise.id)
                            .map { $0 + 1 }

                        Button {
                            toggleSelection(for: exercise)
                        } label: {
                            HStack(spacing: 10) {
                                ExerciseSummaryContent(
                                    name: exercise.name,
                                    categories: exercise.exerciseCategories,
                                    sets: exercise.numberOfSets,
                                    reps: exercise.numberOfReps,
                                    restSeconds: exercise.restSeconds
                                )

                                selectionStatus(
                                    isAlreadyAdded: isAlreadyAdded,
                                    selectionNumber: selectionNumber
                                )
                            }
                            .contentShape(Rectangle())
                            .accessibilityElement(children: .combine)
                        }
                        .buttonStyle(.plain)
                        .disabled(isAlreadyAdded)
                    }
                    .listStyle(.insetGrouped)
                    .appListBackground(tint: AppTheme.energy)
                }
            }
            .background {
                AppBackdrop(tint: AppTheme.energy)
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .tint(AppTheme.brand)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(addButtonTitle) {
                        onAdd(exercisesToAdd)
                        dismiss()
                    }
                    .disabled(selectedExerciseIDs.isEmpty)
                }
            }
        }
    }

    private var addButtonTitle: String {
        guard selectedExerciseIDs.count > 1 else { return "Add" }
        return "Add \(selectedExerciseIDs.count)"
    }

    @ViewBuilder
    private func selectionStatus(
        isAlreadyAdded: Bool,
        selectionNumber: Int?
    ) -> some View {
        if isAlreadyAdded {
            Label("Added", systemImage: "checkmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.success)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppTheme.success.opacity(0.12), in: Capsule())
        } else if let selectionNumber {
            Text("\(selectionNumber)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .frame(minHeight: 28)
                .background(AppTheme.brandGradient, in: Capsule())
                .accessibilityLabel("Selected number \(selectionNumber)")
        } else {
            Image(systemName: "circle")
                .font(.title3)
                .foregroundStyle(.tertiary)
                .accessibilityLabel("Not selected")
        }
    }

    private func toggleSelection(for exercise: ExerciseItem) {
        if let index = selectedExerciseIDs.firstIndex(of: exercise.id) {
            selectedExerciseIDs.remove(at: index)
        } else {
            selectedExerciseIDs.append(exercise.id)
        }
    }
}
