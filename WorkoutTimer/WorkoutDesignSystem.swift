//
//  WorkoutDesignSystem.swift
//  WorkoutTimer
//

import SwiftUI
import UIKit

enum AppTheme {
    static let brand = Color(red: 0.31, green: 0.27, blue: 0.90)
    static let electricBlue = Color(red: 0.12, green: 0.55, blue: 0.98)
    static let energy = Color(red: 0.96, green: 0.47, blue: 0.18)
    static let success = Color(red: 0.12, green: 0.68, blue: 0.42)
    static let rest = Color(red: 0.93, green: 0.28, blue: 0.33)

    static let brandGradient = LinearGradient(
        colors: [brand, electricBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func formattedDuration(_ seconds: Int) -> String {
        guard seconds >= 60 else { return "\(seconds)s" }

        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return remainingSeconds == 0
            ? "\(minutes)m"
            : "\(minutes)m \(remainingSeconds)s"
    }
}

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
        case .core:
            AppTheme.brand
        }
    }

}

struct AppBackdrop: View {
    var tint = AppTheme.brand

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)

            LinearGradient(
                colors: [
                    tint.opacity(0.16),
                    AppTheme.electricBlue.opacity(0.06),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(tint.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 72)
                .offset(x: 150, y: -260)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct AppHero: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let systemImage: String
    var tint = AppTheme.brand

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(
                    LinearGradient(
                        colors: [tint, AppTheme.electricBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .shadow(color: tint.opacity(0.24), radius: 16, y: 8)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 460)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct AppNavigationCard: View {
    let title: String
    var subtitle: String?
    let systemImage: String
    var tint = AppTheme.brand
    var isProminent = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(isProminent ? .white : tint)
                .frame(width: 50, height: 50)
                .background(
                    isProminent ? AnyShapeStyle(.white.opacity(0.16)) : AnyShapeStyle(tint.opacity(0.12)),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(
                            isProminent ? .white.opacity(0.82) : .secondary
                        )
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(
                    isProminent
                        ? AnyShapeStyle(.white.opacity(0.72))
                        : AnyShapeStyle(.tertiary)
                )
                .accessibilityHidden(true)
        }
        .foregroundStyle(isProminent ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isProminent {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppTheme.brandGradient)
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.regularMaterial)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    isProminent ? .white.opacity(0.16) : tint.opacity(0.15),
                    lineWidth: 1
                )
        }
        .shadow(
            color: isProminent ? tint.opacity(0.20) : .clear,
            radius: 16,
            y: 8
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct ExerciseCategoryBadge: View {
    let categoryName: String

    private var category: ExerciseCategory? {
        ExerciseCategory(rawValue: categoryName)
    }

    private var tint: Color {
        category?.themeTint ?? AppTheme.brand
    }

    var body: some View {
        Text(categoryName)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

struct MetricChip: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(.primary.opacity(0.055), in: Capsule())
    }
}

struct ExerciseSummaryContent: View {
    let name: String
    let category: String
    let sets: Int
    let reps: Int
    let restSeconds: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            ExerciseCategoryBadge(categoryName: category)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 6) {
                    metricChips
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        MetricChip(text: "\(sets) sets", systemImage: "square.stack.3d.up")
                        MetricChip(text: "\(reps) reps/sec", systemImage: "repeat")
                    }
                    MetricChip(
                        text: AppTheme.formattedDuration(restSeconds),
                        systemImage: "timer"
                    )
                }
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var metricChips: some View {
        MetricChip(text: "\(sets) sets", systemImage: "square.stack.3d.up")
        MetricChip(text: "\(reps) reps/sec", systemImage: "repeat")
        MetricChip(
            text: AppTheme.formattedDuration(restSeconds),
            systemImage: "timer"
        )
    }
}

struct SettingsRowLabel: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(tint, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
    }
}

private struct AppSurfaceModifier: ViewModifier {
    let tint: Color
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(tint.opacity(0.16), lineWidth: 1)
            }
    }
}

extension View {
    func appSurface(
        tint: Color = AppTheme.brand,
        cornerRadius: CGFloat = 22
    ) -> some View {
        modifier(AppSurfaceModifier(tint: tint, cornerRadius: cornerRadius))
    }

    func appListBackground(tint: Color = AppTheme.brand) -> some View {
        scrollContentBackground(.hidden)
            .background {
                AppBackdrop(tint: tint)
            }
    }
}
