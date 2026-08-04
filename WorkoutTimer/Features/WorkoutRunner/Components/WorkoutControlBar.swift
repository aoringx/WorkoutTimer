//
//  WorkoutControlBar.swift
//  WorkoutTimer
//

import SwiftUI

struct WorkoutControlBar<Content: View>: View {
    let tint: Color
    private let content: Content

    init(
        tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: 680)
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [.clear, tint.opacity(0.42), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
            }
    }
}
