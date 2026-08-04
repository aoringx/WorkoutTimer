//
//  WorkoutUpNextCard.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutUpNextCard: View {
    let title: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "forward.end.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(
                    tint.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("UP NEXT")
                    .font(.caption2.weight(.bold))
                    .tracking(1.1)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .appSurface(tint: tint, cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }
}
