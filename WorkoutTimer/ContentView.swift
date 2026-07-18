//
//  ContentView.swift
//  WorkoutTimer
//
//  Created by Feiyang Xiong on 7/18/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Workout Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                NavigationLink {
                    TimersOptionsView()
                } label: {
                    Label("Timers", systemImage: "timer")
                        .frame(width: 180)
                }
                .buttonStyle(.borderedProminent)
                
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
    }
}

#Preview {
    ContentView()
}
