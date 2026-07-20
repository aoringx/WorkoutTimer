//
//  SavedTimerRow.swift
//  WorkoutTimer
//

import SwiftUI

struct SavedTimerRow: View {
    let timer: WorkoutTimerItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(timer.name)
                    .font(.headline)

                Text("\(timer.exercises.count) exercises • \(timer.sets) sets")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(timer.updatedAt, format: .dateTime.month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if timer.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Pinned")
            }
        }
        .padding(.vertical, 3)
    }
}
