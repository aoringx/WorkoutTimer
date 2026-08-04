//
//  WorkoutSortMenu.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutSortMenu: View {
    @Binding var selection: WorkoutSortOption

    var body: some View {
        Menu {
            Picker("Sort By", selection: $selection) {
                ForEach(WorkoutSortOption.allCases) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort workouts")
    }
}
