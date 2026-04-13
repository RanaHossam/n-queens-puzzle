//
//  ValidateMoveUseCase.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

public struct ValidateMoveUseCase {

    public init() {}

    /// Returns an updated board with conflict flags applied.
    public func execute(board: GameBoard) -> GameBoard {
        let queens = board.placedQueens
        let conflicting = findConflicts(queens: queens)

        var updated = board
        for row in 0..<board.size {
            for col in 0..<board.size {
                let pos = Position(row: row, col: col)
                updated.cells[row][col].isConflict =
                    board.cells[row][col].state == .queen && conflicting.contains(pos)
            }
        }
        return updated
    }

    // MARK: - Private

    private func findConflicts(queens: [Position]) -> Set<Position> {
        var conflicts = Set<Position>()

        for i in 0..<queens.count {
            for j in (i + 1)..<queens.count {
                let a = queens[i]
                let b = queens[j]

                if a.row == b.row || a.col == b.col || a.conflicts(with: b) {
                    conflicts.insert(a)
                    conflicts.insert(b)
                }
            }
        }

        return conflicts
    }
}
