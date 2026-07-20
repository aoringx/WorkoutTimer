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
    @State private var initializationError: Error?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Aaron's\nCalisthenics Timer")
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
            installDefaultData()
        }
        .alert(
            "Couldn’t Load Default Data",
            isPresented: Binding(
                get: { initializationError != nil },
                set: { if !$0 { initializationError = nil } }
            ),
            presenting: initializationError
        ) { _ in
            Button("Retry") {
                installDefaultData()
            }
            Button("Cancel", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    private func installDefaultData() {
        do {
            try DefaultExerciseDatabase.installIfNeeded(in: modelContext)
            try DefaultTimerDatabase.installIfNeeded(in: modelContext)
            initializationError = nil
        } catch {
            initializationError = error
        }
    }
}

#Preview {
    ContentView()
}
