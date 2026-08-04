//
//  WorkoutSortOption.swift
//  WorkoutTimer
//

import Foundation

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
