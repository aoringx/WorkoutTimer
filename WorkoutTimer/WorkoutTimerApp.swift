//
//  WorkoutTimerApp.swift
//  WorkoutTimer
//
//  Created by Feiyang Xiong on 7/18/26.
//

import SwiftUI
import SwiftData

@main
struct WorkoutTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            WorkoutTimerItem.self,
            TimerExerciseItem.self,
            ExerciseItem.self
        ])
    }
}
