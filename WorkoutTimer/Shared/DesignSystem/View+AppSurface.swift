//
//  View+AppSurface.swift
//  WorkoutTimer
//

import SwiftUI

private struct AppSurfaceModifier: ViewModifier {
    let tint: Color
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(tint.opacity(0.16), lineWidth: 1)
            }
    }
}

extension View {
    func appSurface(
        tint: Color = AppTheme.brand,
        cornerRadius: CGFloat = 22
    ) -> some View {
        modifier(AppSurfaceModifier(tint: tint, cornerRadius: cornerRadius))
    }

    func appListBackground(tint: Color = AppTheme.brand) -> some View {
        scrollContentBackground(.hidden)
            .background {
                AppBackdrop(tint: tint)
            }
    }
}
