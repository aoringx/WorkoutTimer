//
//  ExerciseSortOption.swift
//  WorkoutTimer
//

import Foundation

enum ExerciseSortOption: String, CaseIterable, Identifiable {
    case recentlyUpdated
    case name
    case category

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recentlyUpdated: "Recently Updated"
        case .name: "Name (A–Z)"
        case .category: "Categories"
        }
    }

    var systemImage: String {
        switch self {
        case .recentlyUpdated: "clock.arrow.circlepath"
        case .name: "textformat"
        case .category: "tag"
        }
    }

    func sorted(_ exercises: [ExerciseItem]) -> [ExerciseItem] {
        exercises.sorted { first, second in
            return switch self {
            case .recentlyUpdated:
                if first.updatedAt != second.updatedAt {
                    first.updatedAt > second.updatedAt
                } else {
                    nameComesFirst(first.name, second.name)
                }
            case .name:
                nameComesFirst(first.name, second.name)
            case .category:
                if categorySortKey(for: first) != categorySortKey(for: second) {
                    nameComesFirst(
                        categorySortKey(for: first),
                        categorySortKey(for: second)
                    )
                } else {
                    nameComesFirst(first.name, second.name)
                }
            }
        }
    }
}

private func categorySortKey(for exercise: ExerciseItem) -> String {
    exercise.exerciseCategories
        .map(\.rawValue)
        .joined(separator: ", ")
}
