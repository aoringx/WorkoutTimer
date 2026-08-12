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
        case .category: "Type"
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
                    exerciseComesFirstByName(first, second)
                }
            case .name:
                exerciseComesFirstByName(first, second)
            case .category:
                if categorySortKey(for: first) != categorySortKey(for: second) {
                    nameComesFirst(
                        categorySortKey(for: first),
                        categorySortKey(for: second)
                    )
                } else {
                    exerciseComesFirstByName(first, second)
                }
            }
        }
    }
}

private func categorySortKey(for exercise: ExerciseItem) -> String {
    exercise.exerciseCategory.rawValue
}

private func exerciseComesFirstByName(
    _ first: ExerciseItem,
    _ second: ExerciseItem
) -> Bool {
    let nameComparison = first.name.localizedStandardCompare(second.name)
    if nameComparison != .orderedSame {
        return nameComparison == .orderedAscending
    }

    let firstCategory = first.exerciseCategory.rawValue
    let secondCategory = second.exerciseCategory.rawValue
    if firstCategory != secondCategory {
        return nameComesFirst(firstCategory, secondCategory)
    }

    if first.numberOfSets != second.numberOfSets {
        return first.numberOfSets < second.numberOfSets
    }

    if first.numberOfReps != second.numberOfReps {
        return first.numberOfReps < second.numberOfReps
    }

    if first.restSeconds != second.restSeconds {
        return first.restSeconds < second.restSeconds
    }

    return first.id.uuidString < second.id.uuidString
}
