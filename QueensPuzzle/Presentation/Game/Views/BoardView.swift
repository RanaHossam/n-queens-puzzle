//
//  BoardView.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 12/04/2026.
//

import SwiftUI
import QueensDomain

struct BoardView: View {

    let board: GameBoard
    let isWon: Bool
    let onTap: (Position) -> Void

    @Environment(\.appTheme) private var theme

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cellSize = size / CGFloat(board.size)

            ZStack {
                // Interactive cell grid
                VStack(spacing: 0) {
                    ForEach(0..<board.size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<board.size, id: \.self) { col in
                                let pos = Position(row: row, col: col)
                                let cell = board.cells[row][col]
                                CellView(
                                    cell: cell,
                                    isLight: (row + col) % 2 == 0,
                                    isWon: isWon,
                                    winAnimationDelay: winDelay(for: pos),
                                    onTap: { onTap(pos) }
                                )
                                .frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                }
                .frame(width: size, height: size)

                // Grid lines
                Canvas { ctx, canvasSize in
                    for i in 1..<board.size {
                        let x = CGFloat(i) * cellSize
                        let y = CGFloat(i) * cellSize
                        var h = Path()
                        h.move(to: CGPoint(x: 0, y: y))
                        h.addLine(to: CGPoint(x: canvasSize.width, y: y))
                        ctx.stroke(h, with: .color(.black.opacity(0.15)), lineWidth: LineWidth.xs)
                        var v = Path()
                        v.move(to: CGPoint(x: x, y: 0))
                        v.addLine(to: CGPoint(x: x, y: canvasSize.height))
                        ctx.stroke(v, with: .color(.black.opacity(0.15)), lineWidth: LineWidth.xs)
                    }
                }
                .frame(width: size, height: size)
                .allowsHitTesting(false)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .strokeBorder(
                    isWon ? theme.colors.queenGoldTop.opacity(0.8) : Color.black.opacity(0.5),
                    lineWidth: isWon ? LineWidth.lg : LineWidth.md
                )
                .animation(.easeInOut(duration: 0.4), value: isWon)
        )
        .shadow(
            color: isWon ? theme.colors.queenGoldTop.opacity(0.35) : Color.black.opacity(0.12),
            radius: isWon ? Radius.xl : Radius.sm,
            y: Spacing.xs
        )
        .animation(.easeInOut(duration: 0.5), value: isWon)
    }

    // MARK: - Win ripple delay

    /// Stagger queens outward from the last-placed queen using Chebyshev distance.
    private func winDelay(for pos: Position) -> Double {
        guard isWon, let last = board.placedQueens.last else { return 0 }
        let dist = max(abs(pos.row - last.row), abs(pos.col - last.col))
        return Double(dist) * 0.08
    }
}
