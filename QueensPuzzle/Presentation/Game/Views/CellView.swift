//
//  CellView.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 12/04/2026.
//

import SwiftUI
import QueensDomain

struct CellView: View {
    
    @Environment(\.appTheme) private var theme
    
    @State private var queenScale: CGFloat = 1.0
    @State private var isGold: Bool = false
    
    private let cell: Cell
    private let isLight: Bool
    private let isWon: Bool
    private let winAnimationDelay: Double
    private let onTap: () -> Void
    
    init(
        cell: Cell,
        isLight: Bool,
        isWon: Bool,
        winAnimationDelay: Double,
        onTap: @escaping () -> Void
    ) {
        self.cell = cell
        self.isLight = isLight
        self.isWon = isWon
        self.winAnimationDelay = winAnimationDelay
        self.onTap = onTap
    }
    
    private var backgroundColor: Color {
        isLight ? theme.colors.cellLight : theme.colors.cellDark
    }
    
    var body: some View {
        ZStack {
            backgroundColor
            
            switch cell.state {
            case .empty:
                EmptyView()
            case .marked:
                image(for: .marked)
                    .foregroundStyle(theme.colors.accent)
            case .queen:
                queenView
                    .scaleEffect(queenScale)
            }
        }
        .overlay(conflictOverlay)
        .overlay(wonGlowOverlay)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onChange(of: cell.state) { _, newState in
            if newState == .queen { animatePlacement() }
            if newState != .queen { isGold = false }
        }
        .onChange(of: isWon) { _, won in
            if won && cell.state == .queen { animateWin() }
        }
    }
    
    // MARK: - Queen symbol

    @ViewBuilder
    private var queenView: some View {
        if cell.isConflict {
            image(for: .queen)
                .foregroundStyle(theme.colors.queenConflict)
        } else if isGold {
            image(for: .queen)
                .foregroundStyle(theme.colors.queenGoldGradient)
                .shadow(color: theme.colors.queenGoldTop.opacity(0.7), radius: Radius.sm)
        } else {
            image(for: .queen)
                .foregroundStyle(.black)
        }
    }
    
    // MARK: - Overlays
    
    @ViewBuilder
    private var conflictOverlay: some View {
        if cell.isConflict {
            Rectangle()
                .stroke(theme.colors.queenConflict.opacity(0.8), lineWidth: LineWidth.md)
        }
    }
    
    @ViewBuilder
    private var wonGlowOverlay: some View {
        if isGold && cell.state == .queen {
            Rectangle()
                .stroke(theme.colors.queenGlowGradient, lineWidth: LineWidth.md)
        }
    }
    
    private func image(for state: CellState) -> some View {
        Image(systemName: state == .queen ? "crown.fill": "xmark")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 28, maxHeight: 28) // TODO: - optimize for iPAD
            .padding(Spacing.xs)
    }
    
    // MARK: - Animations
    
    private func animatePlacement() {
        queenScale = 0.3
        withAnimation(.spring(response: 0.32, dampingFraction: 0.52)) {
            queenScale = 1.0
        }
    }
    
    private func animateWin() {
        // Staggered: bounce then flip to gold
        DispatchQueue.main.asyncAfter(deadline: .now() + winAnimationDelay) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                queenScale = 1.35
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.18)) {
                queenScale = 1.0
            }
            withAnimation(.easeInOut(duration: 0.35).delay(0.12)) {
                isGold = true
            }
        }
    }
}

