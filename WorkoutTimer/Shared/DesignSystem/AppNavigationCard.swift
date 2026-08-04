//
//  AppNavigationCard.swift
//  WorkoutTimer
//

import SwiftUI

struct AppNavigationCard: View {
    let title: String
    var subtitle: String?
    let systemImage: String
    var tint = AppTheme.brand
    var isProminent = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(isProminent ? .white : tint)
                .frame(width: 50, height: 50)
                .background(
                    isProminent ? AnyShapeStyle(.white.opacity(0.16)) : AnyShapeStyle(tint.opacity(0.12)),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(
                            isProminent ? .white.opacity(0.82) : .secondary
                        )
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(
                    isProminent
                        ? AnyShapeStyle(.white.opacity(0.72))
                        : AnyShapeStyle(.tertiary)
                )
                .accessibilityHidden(true)
        }
        .foregroundStyle(isProminent ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isProminent {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.brandGradient)
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    isProminent ? .white.opacity(0.16) : tint.opacity(0.15),
                    lineWidth: 1
                )
        }
        .shadow(
            color: isProminent ? tint.opacity(0.20) : .clear,
            radius: 16,
            y: 8
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
