//
//  OpenWorkoutView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct OpenWorkoutView: View {
    @Query private var timers: [WorkoutTimerItem]

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
                    description: Text("Create and save a workout to open it here.")
                )
            } else {
                List(orderedTimers) { timer in
                    NavigationLink {
                        WorkoutRunnerView(timer: timer)
                    } label: {
                        SavedWorkoutRow(timer: timer)
                    }
                }
                .listStyle(.insetGrouped)
                .appListBackground()
            }
        }
        .background {
            AppBackdrop()
        }
        .navigationTitle("Start Workout")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.brand)
        .toolbar {
            if !timers.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    WorkoutSortMenu(selection: $sortOption)
                }
            }
        }
    }
}
