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
                || exercise.exerciseCategory.rawValue.localizedStandardContains(searchText)
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
                        Text("Create exercises before adding them to a timer.")
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
                            || excludedExerciseNames.contains(normalizedName(exercise.name))
                        let selectionNumber = selectedExerciseIDs.firstIndex(of: exercise.id)
                            .map { $0 + 1 }

                        Button {
                            toggleSelection(for: exercise)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(
                                        "\(exercise.exerciseCategory.rawValue) • "
                                            + "\(exercise.numberOfSets) × \(exercise.numberOfReps)"
                                    )
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if isAlreadyAdded {
                                    Text("Added")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.secondary)
                                } else if let selectionNumber {
                                    Text("\(selectionNumber)")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                        .frame(width: 24, height: 24)
                                        .background(.tint, in: Circle())
                                        .accessibilityLabel(
                                            "Selected number \(selectionNumber)"
                                        )
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.tertiary)
                                        .accessibilityLabel("Not selected")
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isAlreadyAdded)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
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

    private func toggleSelection(for exercise: ExerciseItem) {
        if let index = selectedExerciseIDs.firstIndex(of: exercise.id) {
            selectedExerciseIDs.remove(at: index)
        } else {
            selectedExerciseIDs.append(exercise.id)
        }
    }

    private func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
