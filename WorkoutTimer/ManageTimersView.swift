//
//  ManageTimersView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct ManageTimersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timers: [WorkoutTimerItem]

    @State private var updateError: Error?

    @AppStorage(AppSettingKey.timerSortOption)
    private var sortOption = TimerSortOption.recentlyUpdated

    private var orderedTimers: [WorkoutTimerItem] {
        sortOption.sorted(timers)
    }

    var body: some View {
        Group {
            if timers.isEmpty {
                ContentUnavailableView(
                    "No Saved Timers",
                    systemImage: "timer",
                    description: Text("Timers you save will appear here.")
                )
            } else {
                List {
                    ForEach(orderedTimers) { timer in
                        NavigationLink {
                            EditTimerView(timer: timer)
                        } label: {
                            SavedTimerRow(timer: timer)
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
                            .tint(timer.isPinned ? .gray : .orange)
                        }
                    }
                    .onDelete(perform: deleteTimers)
                    .onMove(perform: moveTimers)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Manage Timers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !timers.isEmpty {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    TimerSortMenu(selection: $sortOption)
                    EditButton()
                }
            }
        }
        .alert(
            "Couldn’t Update Timer",
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
            modelContext.delete(orderedTimers[index])
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
