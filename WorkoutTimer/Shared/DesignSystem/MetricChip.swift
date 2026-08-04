//
//  MetricChip.swift
//  WorkoutTimer
//

import SwiftUI

struct MetricChip: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Image(systemName: systemImage)
                .fixedSize()
                .accessibilityHidden(true)

            Text(text)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
        }
        .font(.caption.weight(.semibold))
        .monospacedDigit()
        .foregroundStyle(.secondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(.primary.opacity(0.055), in: Capsule())
        .fixedSize(horizontal: false, vertical: true)
    }
}
