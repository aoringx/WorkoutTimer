//
//  OpenTimerView.swift
//  WorkoutTimer
//

import SwiftUI
import SwiftData

struct OpenTimerView: View {
    @Query(sort: \WorkoutTimerItem.updatedAt, order: .reverse)
    private var timers: [WorkoutTimerItem]

    private var orderedTimers: [WorkoutTimerItem] {
        timers.sorted { first, second in
            if first.isPinned != second.isPinned {
                return first.isPinned
            }

            return first.updatedAt > second.updatedAt
        }
    }

    var body: some View {
        Group {
            if timers.isEmpty {
                ContentUnavailableView(
                    "No Saved Timers",
                    systemImage: "timer",
                    description: Text("Generate and save a timer to open it here.")
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
    }
}
