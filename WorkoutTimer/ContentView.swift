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
            ZStack {
                AppBackdrop()

                ScrollView {
                    VStack(spacing: 30) {
                        Text("Aaron’s Calisthenics")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        VStack(spacing: 14) {
                            NavigationLink {
                                WorkoutsView()
                            } label: {
                                AppNavigationCard(
                                    title: "Workouts",
                                    systemImage: "timer",
                                    tint: AppTheme.brand
                                )
                            }

                            NavigationLink {
                                ExercisesOptionsView()
                            } label: {
                                AppNavigationCard(
                                    title: "Exercise Library",
                                    systemImage: "figure.strengthtraining.traditional",
                                    tint: AppTheme.energy
                                )
                            }

                            NavigationLink {
                                SettingsView()
                            } label: {
                                AppNavigationCard(
                                    title: "Settings",
                                    systemImage: "slider.horizontal.3",
                                    tint: AppTheme.electricBlue
                                )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: 640)
                    .padding(.horizontal, 20)
                    .padding(.top, 52)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
        }
        .tint(AppTheme.brand)
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
            try DefaultWorkoutDatabase.installIfNeeded(in: modelContext)
            initializationError = nil
        } catch {
            modelContext.rollback()
            initializationError = error
        }
    }
}

#Preview {
    ContentView()
}
