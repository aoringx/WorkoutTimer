//
//  AppBackdrop.swift
//  WorkoutTimer
//

import SwiftUI
import UIKit

struct AppBackdrop: View {
    var tint = AppTheme.brand

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)

            LinearGradient(
                colors: [
                    tint.opacity(0.16),
                    AppTheme.electricBlue.opacity(0.06),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(tint.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 72)
                .offset(x: 150, y: -260)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
