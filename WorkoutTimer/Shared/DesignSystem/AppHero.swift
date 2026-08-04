//
//  AppHero.swift
//  WorkoutTimer
//

import SwiftUI

struct AppHero: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let systemImage: String
    var tint = AppTheme.brand

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(
                    LinearGradient(
                        colors: [tint, AppTheme.electricBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .shadow(color: tint.opacity(0.24), radius: 16, y: 8)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 460)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
