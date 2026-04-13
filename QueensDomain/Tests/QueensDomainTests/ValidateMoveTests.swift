import Testing
@testable import QueensDomain

@Suite("ValidateMoveUseCase")
struct ValidateMoveTests {

    private let generate = GeneratePuzzleUseCase()
    private let validate = ValidateMoveUseCase()
    private let checkWin = CheckWinUseCase(validateMove: ValidateMoveUseCase())

    // MARK: - Helpers

    private func make4x4Board() -> GameBoard { generate.execute(size: 4) }

    private func placeQueen(on board: GameBoard, row: Int, col: Int) -> GameBoard {
        let pos = Position(row: row, col: col)
        var b = board.tapping(at: pos)   // → marked
        b = b.tapping(at: pos)           // → queen
        return b
    }

    // MARK: - No conflicts on empty board

    @Test("Empty board has no conflicts")
    func emptyBoardHasNoConflicts() {
        let board = generate.execute(size: 5)
        let result = validate.execute(board: board)
        #expect(result.allCells.allSatisfy { !$0.isConflict })
    }

    // MARK: - Row conflict

    @Test("Two queens in same row are conflicting")
    func twoQueensInSameRowAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 0)
        board = placeQueen(on: board, row: 0, col: 3)
        let result = validate.execute(board: board)
        #expect(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    // MARK: - Column conflict

    @Test("Two queens in same column are conflicting")
    func twoQueensInSameColumnAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 2)
        board = placeQueen(on: board, row: 3, col: 2)
        let result = validate.execute(board: board)
        #expect(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    // MARK: - Diagonal conflict

    @Test("Queens on same diagonal are conflicting")
    func queensOnSameDiagonalAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 0)
        board = placeQueen(on: board, row: 2, col: 2)   // same diagonal, distance 2
        let result = validate.execute(board: board)
        #expect(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    @Test("Diagonally adjacent queens are conflicting")
    func diagonallyAdjacentQueensAreConflicting() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 1, col: 1)
        board = placeQueen(on: board, row: 2, col: 2)
        let result = validate.execute(board: board)
        #expect(result.placedQueens.allSatisfy { result[$0].isConflict })
    }

    // MARK: - Win detection

    @Test("Known valid 4×4 solution wins")
    func validSolutionWins() {
        var board = make4x4Board()
        for (row, col) in [(0,1),(1,3),(2,0),(3,2)] {
            board = placeQueen(on: board, row: row, col: col)
        }
        #expect(checkWin.execute(board: board))
    }

    @Test("Partial placement does not win")
    func partialPlacementDoesNotWin() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 0, col: 1)
        board = placeQueen(on: board, row: 1, col: 3)
        #expect(!checkWin.execute(board: board))
    }

    // MARK: - Tap cycle

    @Test("Tap cycles empty → marked → queen → empty")
    func tapCyclesCorrectly() {
        let board = make4x4Board()
        let pos = Position(row: 0, col: 0)
        #expect(board[pos].state == .empty)
        let afterFirst  = board.tapping(at: pos)
        #expect(afterFirst[pos].state == .marked)
        let afterSecond = afterFirst.tapping(at: pos)
        #expect(afterSecond[pos].state == .queen)
        let afterThird  = afterSecond.tapping(at: pos)
        #expect(afterThird[pos].state == .empty)
    }

    @Test("Reset clears all cells")
    func resetClearsAllCells() {
        var board = make4x4Board()
        board = placeQueen(on: board, row: 1, col: 1)
        board = placeQueen(on: board, row: 3, col: 3)
        let reset = board.reset()
        #expect(reset.allCells.allSatisfy { $0.state == .empty && !$0.isConflict })
    }
}
