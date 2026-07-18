//
//  GenerateTimerView.swift
//  WorkoutTimer
//

import SwiftUI

struct GenerateTimerView: View {
    init(timers: [WorkoutTimerItem] = []) { }

    var body: some View {
        Color.clear
            .navigationTitle("Generate New Timer")
            .navigationBarTitleDisplayMode(.inline)
    }
}
