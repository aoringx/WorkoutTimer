//
//  WorkoutPhaseCard.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutPhaseCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let steps: [String]

    var body: some View {
        VStack(spacing: 26) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
                .shadow(color: tint.opacity(0.24), radius: 16, y: 8)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .monospacedDigit()
                            .foregroundStyle(tint)
                            .frame(width: 30, height: 30)
                            .background(tint.opacity(0.13), in: Circle())

                        Text(step)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(26)
        .background(
            tint.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .appSurface(tint: tint, cornerRadius: 28)
        .shadow(color: tint.opacity(0.10), radius: 18, y: 10)
    }
}
