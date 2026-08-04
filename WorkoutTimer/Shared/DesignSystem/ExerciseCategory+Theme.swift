//
//  ExerciseCategory+Theme.swift
//  WorkoutTimer
//

import SwiftUI

extension ExerciseCategory {
    var themeTint: Color {
        switch self {
        case .planche:
            .purple
        case .push:
            AppTheme.energy
        case .pull:
            AppTheme.electricBlue
        case .legs:
            AppTheme.success
        case .handstand:
            .teal
        case .lSit:
            .indigo
        case .core:
            AppTheme.brand
        }
    }
}
