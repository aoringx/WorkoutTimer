//
//  ExercisesOptionsView.swift
//  WorkoutTimer
//
//  Created by Feiyang Xiong on 7/18/26.
//

import SwiftUI
import SwiftData

struct ExercisesOptionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [ExerciseItem]

    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory?
    @State private var editorTarget: ExerciseEditorTarget?
    @State private var saveError: Error?

    @AppStorage(AppSettingKey.exerciseSortOption)
    private var sortOption = ExerciseSortOption.name

    @AppStorage(AppSettingKey.defaultSets)
    private var defaultSets = AppSettingDefault.sets

    @AppStorage(AppSettingKey.defaultReps)
    private var defaultReps = AppSettingDefault.reps

    @AppStorage(AppSettingKey.defaultRestSeconds)
    private var defaultRestSeconds = AppSettingDefault.restSeconds

    private var visibleExercises: [ExerciseItem] {
        let filteredExercises = exercises.filter { exercise in
            let matchesCategory = selectedCategory == nil
                || exercise.exerciseCategory == selectedCategory
            let matchesSearch = searchText.isEmpty
                || exercise.name.localizedStandardContains(searchText)
                || exercise.notes.localizedStandardContains(searchText)

            return matchesCategory && matchesSearch
        }

        return sortOption.sorted(filteredExercises)
    }

    var body: some View {
        Group {
            if exercises.isEmpty {
                ContentUnavailableView {
                    Label("No Exercises", systemImage: "figure.strengthtraining.traditional")
                } description: {
                    Text("Build your exercise library by adding your first exercise.")
                }
            } else if visibleExercises.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else if visibleExercises.isEmpty, let selectedCategory {
                ContentUnavailableView {
                    Text("No \(selectedCategory.rawValue) Exercises")
                } description: {
                    Text("Try another type or add an exercise to this category.")
                }
            } else {
                List {
                    ForEach(visibleExercises) { exercise in
                        Button {
                            editorTarget = .edit(exercise)
                        } label: {
                            ExerciseRow(exercise: exercise)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                delete(exercise)
                            }
                        }
                    }
                    .onDelete(perform: deleteExercises)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Exercises")
        .searchable(text: $searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button {
                        selectedCategory = nil
                    } label: {
                        filterLabel("All Types", isSelected: selectedCategory == nil)
                    }

                    ForEach(ExerciseCategory.allCases) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            filterLabel(
                                category.rawValue,
                                isSelected: selectedCategory == category
                            )
                        }
                    }
                } label: {
                    Label(
                        selectedCategory?.rawValue ?? "All Types",
                        systemImage: "line.3.horizontal.decrease.circle"
                    )
                }
                .accessibilityLabel("Filter exercise type")
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(ExerciseSortOption.allCases) { option in
                            Label(option.title, systemImage: option.systemImage)
                                .tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                .accessibilityLabel("Sort exercises")

                Button {
                    editorTarget = .new
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add exercise")
            }
        }
        .fullScreenCover(item: $editorTarget) { target in
            ExerciseEditorView(
                exercise: target.exercise,
                defaultSets: defaultSets,
                defaultReps: defaultReps,
                defaultRestSeconds: defaultRestSeconds
            )
        }
        .alert(
            "Couldn’t Delete Exercise",
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
    private func filterLabel(
        _ title: String,
        isSelected: Bool
    ) -> some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }

    private func delete(_ exercise: ExerciseItem) {
        withAnimation {
            modelContext.delete(exercise)
        }
        saveChanges()
    }

    private func deleteExercises(at offsets: IndexSet) {
        withAnimation {
            for offset in offsets {
                modelContext.delete(visibleExercises[offset])
            }
        }
        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            saveError = error
        }
    }
}

private enum ExerciseEditorTarget: Identifiable {
    case new
    case edit(ExerciseItem)

    var id: String {
        switch self {
        case .new:
            "new"
        case .edit(let exercise):
            exercise.id.uuidString
        }
    }

    var exercise: ExerciseItem? {
        guard case .edit(let exercise) = self else { return nil }
        return exercise
    }
}

private struct ExerciseRow: View {
    let exercise: ExerciseItem

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(exercise.exerciseCategory.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(
                    "\(exercise.numberOfSets) sets × \(exercise.numberOfReps) reps • "
                        + "\(exercise.restSeconds) sec rest"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens the exercise editor")
    }
}
