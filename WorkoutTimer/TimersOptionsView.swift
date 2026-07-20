//
//  TimersOptionsView.swift
//  WorkoutTimer
//

import SwiftUI

struct TimersOptionsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Timers")
                .font(.largeTitle)
                .fontWeight(.bold)

            NavigationLink {
                GenerateTimerView()
            } label: {
                Label("Create New Timer", systemImage: "plus.circle")
                    .frame(width: 220)
            }
            .buttonStyle(.bordered)

            NavigationLink {
                OpenTimerView()
            } label: {
                Label("Open Timer", systemImage: "folder")
                    .frame(width: 220)
            }
            .buttonStyle(.bordered)

            NavigationLink {
                ManageTimersView()
            } label: {
                Label("Manage Timers", systemImage: "slider.horizontal.3")
                    .frame(width: 220)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Timers")
        .navigationBarTitleDisplayMode(.inline)
    }
}
