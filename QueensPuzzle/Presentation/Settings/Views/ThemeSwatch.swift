//
//  ThemeSwatch.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 13/04/2026.
//

import SwiftUI

struct ThemeSwatch: View {

    let identifier: ThemeIdentifier
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let swatch = identifier.swatchColors

        Button(action: onTap) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    // Gradient fill
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(
                            LinearGradient(
                                colors: [swatch.top, swatch.bottom],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Selected ring + checkmark
                    if isSelected {
                        RoundedRectangle(cornerRadius: Radius.lg)
                            .strokeBorder(.white.opacity(0.9), lineWidth: 3)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    }
                }
                .frame(width: 60, height: 60)
                .shadow(
                    color: isSelected ? swatch.top.opacity(0.45) : .black.opacity(0.12),
                    radius: isSelected ? 8 : 4,
                    y: 3
                )
                .scaleEffect(isSelected ? 1.08 : 1.0)

                Text(identifier.displayName)
                    .font(Typography.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? swatch.top : .secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(identifier.displayName)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
