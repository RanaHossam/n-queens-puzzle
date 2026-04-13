//
//  SizeTileView.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 12/04/2026.
//

import SwiftUI
import QueensDomain

struct SizeTile: View {
    
    let size: Int
    let bestTime: BestTime?
    let action: () -> Void
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(L10n.boardSize(size))
                    .font(Typography.title3Bold)
                if let bt = bestTime {
                    Text(bt.formattedTime)
                        .font(Typography.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text(L10n.noBestTime)
                        .font(Typography.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(theme.colors.accent.opacity(0.3), lineWidth: LineWidth.sm)
            )
        }
        .buttonStyle(.plain)
    }
}
