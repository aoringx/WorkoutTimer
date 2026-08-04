//
//  String+Normalization.swift
//  WorkoutTimer
//

import Foundation

extension String {
    var normalizedForComparison: String {
        trimmingCharacters(in: .whitespacesAndNewlines).folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        )
    }
}
