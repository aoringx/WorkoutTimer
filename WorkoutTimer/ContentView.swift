//
//  ContentView.swift
//  WorkoutTimer
//
//  Created by Feiyang Xiong on 7/18/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(LegacyExerciseCleanup.didCleanupKey)
    private var didRemoveExperimentalExercises = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Aaron's\nWorkout Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                NavigationLink {
                    TimersOptionsView()
                } label: {
                    Label("Timers", systemImage: "timer")
                        .frame(width: 180)
                }
                .buttonStyle(.bordered)
                
                NavigationLink {
                    ExercisesOptionsView()
                } label: {
                    Label("Exercises", systemImage: "figure.strengthtraining.traditional")
                        .frame(width: 180)
                }
                .buttonStyle(.bordered)


                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .frame(width: 180)
                }
                .buttonStyle(.bordered)

            }
            .padding()
        }
        .task {
            guard !didRemoveExperimentalExercises else { return }

            do {
                try LegacyExerciseCleanup.removeSeededExercises(in: modelContext)
                didRemoveExperimentalExercises = true
            } catch {
                // Leave the flag unset so cleanup can retry on a later launch.
            }
        }
    }
}

#Preview {
    ContentView()
}
