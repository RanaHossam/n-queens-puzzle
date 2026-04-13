import XCTest
@testable import QueensDomain

final class CheckWinUseCaseTests: XCTestCase {

    private let sut = CheckWinUseCase(validateMove: ValidateMoveUseCase())

    // MARK: - Helpers

    private func placeQueen(on board: GameBoard, row: Int, col: Int) -> GameBoard {
        let pos = Position(row: row, col: col)
        var b = board.tapping(at: pos)
        b = b.tapping(at: pos)
        return b
    }

    private func emptyBoard(size: Int) -> GameBoard {
        GameBoard.mockEmpty(size: size)
    }

    // MARK: - Win

    func test_validSolution_wins() {
        // Known 4×4 solution: (0,1),(1,3),(2,0),(3,2)
        var board = emptyBoard(size: 4)
        for (row, col) in [(0,1),(1,3),(2,0),(3,2)] {
            board = placeQueen(on: board, row: row, col: col)
        }
        XCTAssertTrue(sut.execute(board: board))
    }

    func test_anotherValidSolution_wins() {
        // Known 5×5 solution: (0,0),(1,2),(2,4),(3,1),(4,3)
        var board = emptyBoard(size: 5)
        for (row, col) in [(0,0),(1,2),(2,4),(3,1),(4,3)] {
            board = placeQueen(on: board, row: row, col: col)
        }
        XCTAssertTrue(sut.execute(board: board))
    }

    // MARK: - Not win

    func test_partialPlacement_doesNotWin() {
        var board = emptyBoard(size: 4)
        board = placeQueen(on: board, row: 0, col: 1)
        board = placeQueen(on: board, row: 1, col: 3)
        XCTAssertFalse(sut.execute(board: board))
    }

    func test_emptyBoard_doesNotWin() {
        let board = emptyBoard(size: 4)
        XCTAssertFalse(sut.execute(board: board))
    }

    func test_conflictingQueens_doesNotWin() {
        // (0,0) and (1,1) share a diagonal → conflict
        var board = emptyBoard(size: 4)
        board = placeQueen(on: board, row: 0, col: 0)
        board = placeQueen(on: board, row: 1, col: 1)
        board = placeQueen(on: board, row: 2, col: 3)
        board = placeQueen(on: board, row: 3, col: 2)
        XCTAssertFalse(sut.execute(board: board))
    }

    func test_nQueens_allPlacedWithConflict_doesNotWin() {
        // All N queens in the same column → conflict
        var board = emptyBoard(size: 4)
        for row in 0..<4 {
            board = placeQueen(on: board, row: row, col: 0)
        }
        XCTAssertFalse(sut.execute(board: board))
    }
}
