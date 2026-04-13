import XCTest
@testable import QueensDomain

final class ValidateMoveTests: XCTestCase {

    private let generate  = GeneratePuzzleUseCase()
    private let validate  = ValidateMoveUseCase()
    private let checkWin  = CheckWinUseCase(validateMove: ValidateMoveUseCase())

    // MARK: - No conflicts on empty board

    func test_emptyBoardHasNoConflicts() {
        let board  = generate.execute(size: 5)
        let result = validate.execute(board: board)
        XCTAssertTrue(result.allCells.allSatisfy { !$0.isConflict })
    }

    // MARK: - Row conflict

    func test_twoQueensInSameRowAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 0)
        board = placeQueen(on: board, row: 0, col: 3)   // same row
        let result = validate.execute(board: board)
        XCTAssertTrue(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    // MARK: - Column conflict

    func test_twoQueensInSameColumnAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 2)
        board = placeQueen(on: board, row: 3, col: 2)   // same column
        let result = validate.execute(board: board)
        XCTAssertTrue(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    // MARK: - Diagonal conflict

    func test_queensOnSameDiagonalAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 0)
        board = placeQueen(on: board, row: 2, col: 2)   // same diagonal, distance 2
        let result = validate.execute(board: board)
        XCTAssertTrue(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    func test_diagonallyAdjacentQueensAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 1, col: 1)
        board = placeQueen(on: board, row: 2, col: 2)   // adjacent diagonal
        let result = validate.execute(board: board)
        XCTAssertTrue(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    // MARK: - Win detection

    /// Places a known valid 4×4 solution: (0,1),(1,3),(2,0),(3,2).
    func test_validSolutionWins() {
        var board = make4x4Board()
        let solution = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 3),
            Position(row: 2, col: 0),
            Position(row: 3, col: 2)
        ]
        for pos in solution {
            board = placeQueen(on: board, row: pos.row, col: pos.col)
        }
        XCTAssertTrue(checkWin.execute(board: board), "Placing all solution queens should win")
    }

    func test_partialPlacementDoesNotWin() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 1)
        board = placeQueen(on: board, row: 1, col: 3)
        XCTAssertFalse(checkWin.execute(board: board))
    }

    // MARK: - Tap cycle

    func test_tapCyclesEmptyToMarkedToQueenToEmpty() {
        let board = make4x4Board()
        let pos = Position(row: 0, col: 0)
        XCTAssertEqual(board[pos].state, .empty)
        let afterFirst  = board.tapping(at: pos)
        XCTAssertEqual(afterFirst[pos].state, .marked)
        let afterSecond = afterFirst.tapping(at: pos)
        XCTAssertEqual(afterSecond[pos].state, .queen)
        let afterThird  = afterSecond.tapping(at: pos)
        XCTAssertEqual(afterThird[pos].state, .empty)
    }

    func test_resetClearsAllCells() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 1, col: 1)
        board = placeQueen(on: board, row: 3, col: 3)
        let reset = board.reset()
        XCTAssertTrue(reset.allCells.allSatisfy { $0.state == .empty && !$0.isConflict })
    }

    // MARK: - Helpers

    private func make4x4Board() -> GameBoard {
        generate.execute(size: 4)
    }

    private func placeQueen(on board: GameBoard, row: Int, col: Int) -> GameBoard {
        let pos = Position(row: row, col: col)
        var b = board.tapping(at: pos)   // → marked
        b = b.tapping(at: pos)           // → queen
        return b
    }
}
