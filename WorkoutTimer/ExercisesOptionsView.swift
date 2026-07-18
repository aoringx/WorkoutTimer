//
//  ExercisesOptionsView.swift
//  WorkoutTimer
//
//  Created by Feiyang Xiong on 7/18/26.
//

import SwiftUI

struct ExercisesOptionsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Exercises")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.inline)
    }
}
