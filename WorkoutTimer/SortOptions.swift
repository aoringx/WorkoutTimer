//
//  SortOptions.swift
//  WorkoutTimer
//

import Foundation
import SwiftUI

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

enum WorkoutSortOption: String, CaseIterable, Identifiable {
    case recentlyUpdated
    case name
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recentlyUpdated: "Recently Updated"
        case .name: "Name (A–Z)"
        case .manual: "Manual"
        }
    }

    var systemImage: String {
        switch self {
        case .recentlyUpdated: "clock.arrow.circlepath"
        case .name: "textformat"
        case .manual: "line.3.horizontal"
        }
    }

    func sorted(_ timers: [WorkoutTimerItem]) -> [WorkoutTimerItem] {
        timers.sorted { first, second in
            if self != .manual, first.isPinned != second.isPinned {
                return first.isPinned
            }

            return switch self {
            case .recentlyUpdated:
                if first.updatedAt != second.updatedAt {
                    first.updatedAt > second.updatedAt
                } else {
                    nameComesFirst(first.name, second.name)
                }
            case .name:
                nameComesFirst(first.name, second.name)
            case .manual:
                if first.manualSortOrder != second.manualSortOrder {
                    first.manualSortOrder < second.manualSortOrder
                } else {
                    nameComesFirst(first.name, second.name)
                }
            }
        }
    }
}

struct WorkoutSortMenu: View {
    @Binding var selection: WorkoutSortOption

    var body: some View {
        Menu {
            Picker("Sort By", selection: $selection) {
                ForEach(WorkoutSortOption.allCases) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort workouts")
    }
}

extension String {
    var normalizedForComparison: String {
        trimmingCharacters(in: .whitespacesAndNewlines).folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        )
    }
}

private func nameComesFirst(_ first: String, _ second: String) -> Bool {
    first.localizedStandardCompare(second) == .orderedAscending
}
