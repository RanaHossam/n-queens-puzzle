//
//  CheckWinUseCase.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

public struct CheckWinUseCase {

    private let validateMove: ValidateMoveUseCase

    public init(validateMove: ValidateMoveUseCase) {
        self.validateMove = validateMove
    }

    public func execute(board: GameBoard) -> Bool {
        let queens = board.placedQueens
        guard queens.count == board.size else { return false }
        let validated = validateMove.execute(board: board)
        let didWin = validated.placedQueens.allSatisfy { !validated[$0].isConflict }
        return didWin
    }
}
