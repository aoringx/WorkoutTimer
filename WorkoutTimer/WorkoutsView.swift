//
//  WorkoutsView.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutsView: View {
    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView {
                VStack(spacing: 14) {
                    NavigationLink {
                        OpenWorkoutView()
                    } label: {
                        AppNavigationCard(
                            title: "Start a Workout",
                            systemImage: "play.fill",
                            tint: AppTheme.brand,
                        )
                    }

                    NavigationLink {
                        CreateWorkoutView()
                    } label: {
                        AppNavigationCard(
                            title: "Build a Workout",
                            systemImage: "plus",
                            tint: AppTheme.energy
                        )
                    }

                    NavigationLink {
                        ManageWorkoutsView()
                    } label: {
                        AppNavigationCard(
                            title: "Manage Workouts",
                            systemImage: "slider.horizontal.3",
                            tint: AppTheme.electricBlue
                        )
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 640)
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
            }
        }
        .tint(AppTheme.brand)
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.inline)
    }
}
