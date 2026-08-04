//
//  WrappingHStack.swift
//  WorkoutTimer
//

import SwiftUI

/// Keeps each chip intact when it fits and moves overflow chips to the next row.
struct WrappingHStack: Layout {
    var horizontalSpacing: CGFloat = 6
    var verticalSpacing: CGFloat = 6

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        arrangement(
            subviews: subviews,
            maximumWidth: finiteWidth(proposal.width)
        ).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = arrangement(
            subviews: subviews,
            maximumWidth: max(0, bounds.width)
        )

        for item in result.items {
            let x = if subviews.layoutDirection == .rightToLeft {
                bounds.maxX - item.origin.x - item.size.width
            } else {
                bounds.minX + item.origin.x
            }

            subviews[item.index].place(
                at: CGPoint(x: x, y: bounds.minY + item.origin.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: item.size.width,
                    height: item.size.height
                )
            )
        }
    }

    private func arrangement(
        subviews: Subviews,
        maximumWidth: CGFloat?
    ) -> Arrangement {
        guard !subviews.isEmpty else { return Arrangement() }

        let widthLimit = maximumWidth ?? .greatestFiniteMagnitude
        var result = Arrangement()
        var nextX: CGFloat = 0
        var nextY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var rowHasItems = false
        var widestRow: CGFloat = 0

        for index in subviews.indices {
            let childSize = measuredSize(
                of: subviews[index],
                maximumWidth: maximumWidth
            )
            let gap = rowHasItems ? horizontalSpacing : 0

            if rowHasItems, nextX + gap + childSize.width > widthLimit {
                nextX = 0
                nextY += rowHeight + verticalSpacing
                rowHeight = 0
                rowHasItems = false
            }

            if rowHasItems {
                nextX += horizontalSpacing
            }

            result.items.append(
                Item(
                    index: index,
                    origin: CGPoint(x: nextX, y: nextY),
                    size: childSize
                )
            )
            nextX += childSize.width
            rowHeight = max(rowHeight, childSize.height)
            widestRow = max(widestRow, nextX)
            rowHasItems = true
        }

        result.size = CGSize(width: widestRow, height: nextY + rowHeight)
        return result
    }

    private func measuredSize(
        of subview: LayoutSubview,
        maximumWidth: CGFloat?
    ) -> CGSize {
        let intrinsicSize = subview.sizeThatFits(.unspecified)

        guard let maximumWidth, intrinsicSize.width > maximumWidth else {
            return intrinsicSize
        }

        return subview.sizeThatFits(
            ProposedViewSize(width: maximumWidth, height: nil)
        )
    }

    private func finiteWidth(_ width: CGFloat?) -> CGFloat? {
        guard let width, width.isFinite else { return nil }
        return max(0, width)
    }
}

private struct Item {
    let index: Int
    let origin: CGPoint
    let size: CGSize
}

private struct Arrangement {
    var items: [Item] = []
    var size: CGSize = .zero
}
