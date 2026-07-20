//
//  OpenTimerView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct OpenTimerView: View {
    @Query private var timers: [WorkoutTimerItem]

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
                    description: Text("Create and save a timer to open it here.")
                )
            } else {
                List(orderedTimers) { timer in
                    NavigationLink {
                        TimerRunnerView(timer: timer)
                    } label: {
                        SavedTimerRow(timer: timer)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Open Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !timers.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    TimerSortMenu(selection: $sortOption)
                }
            }
        }
    }
}
