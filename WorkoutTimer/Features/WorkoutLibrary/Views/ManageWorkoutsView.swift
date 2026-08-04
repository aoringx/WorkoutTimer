//
//  ManageWorkoutsView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct ManageWorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timers: [WorkoutTimerItem]

    @State private var updateError: Error?

    @AppStorage(AppSettingKey.timerSortOption)
    private var sortOption = WorkoutSortOption.recentlyUpdated

    private var orderedTimers: [WorkoutTimerItem] {
        sortOption.sorted(timers)
    }

    var body: some View {
        Group {
            if timers.isEmpty {
                ContentUnavailableView(
                    "No Saved Workouts",
                    systemImage: "timer",
                    description: Text("Workouts you save will appear here.")
                )
            } else {
                List {
                    ForEach(orderedTimers) { timer in
                        NavigationLink {
                            EditWorkoutView(timer: timer)
                        } label: {
                            SavedWorkoutRow(timer: timer)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                togglePin(for: timer)
                            } label: {
                                Label(
                                    timer.isPinned ? "Unpin" : "Pin",
                                    systemImage: timer.isPinned ? "pin.slash" : "pin"
                                )
                            }
                            .tint(timer.isPinned ? .gray : AppTheme.energy)
                        }
                        .deleteDisabled(timer.isCategoryWorkout)
                    }
                    .onDelete(perform: deleteTimers)
                    .onMove(perform: moveTimers)
                }
                .listStyle(.insetGrouped)
                .appListBackground(tint: AppTheme.electricBlue)
            }
        }
        .background {
            AppBackdrop(tint: AppTheme.electricBlue)
        }
        .navigationTitle("Manage Workouts")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.brand)
        .toolbar {
            if !timers.isEmpty {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    WorkoutSortMenu(selection: $sortOption)
                    EditButton()
                }
            }
        }
        .alert(
            "Couldn’t Update Workout",
            isPresented: Binding(
                get: { updateError != nil },
                set: { if !$0 { updateError = nil } }
            ),
            presenting: updateError
        ) { _ in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    private func deleteTimers(at offsets: IndexSet) {
        for index in offsets {
            let timer = orderedTimers[index]
            guard !timer.isCategoryWorkout else { continue }
            modelContext.delete(timer)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            updateError = error
        }
    }

    private func moveTimers(from source: IndexSet, to destination: Int) {
        var reorderedTimers = orderedTimers
        reorderedTimers.move(fromOffsets: source, toOffset: destination)

        for (position, timer) in reorderedTimers.enumerated() {
            timer.manualSortOrder = position
        }

        let previousSortOption = sortOption
        sortOption = .manual

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            sortOption = previousSortOption
            updateError = error
        }
    }

    private func togglePin(for timer: WorkoutTimerItem) {
        timer.isPinned.toggle()
        timer.updatedAt = Date()

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            updateError = error
        }
    }
}
