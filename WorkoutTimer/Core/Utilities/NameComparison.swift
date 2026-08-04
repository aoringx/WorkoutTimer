//
//  NameComparison.swift
//  WorkoutTimer
//

import Foundation

func nameComesFirst(_ first: String, _ second: String) -> Bool {
    first.localizedStandardCompare(second) == .orderedAscending
}
