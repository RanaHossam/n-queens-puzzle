import Testing
@testable import QueensDomain

@Suite("CheckWinUseCase")
struct CheckWinUseCaseTests {

    private let sut = CheckWinUseCase(validateMove: ValidateMoveUseCase())

    // MARK: - Helpers

    private func placeQueen(on board: GameBoard, row: Int, col: Int) -> GameBoard {
        let pos = Position(row: row, col: col)
        var b = board.tapping(at: pos)
        b = b.tapping(at: pos)
        return b
    }

    private func emptyBoard(size: Int) -> GameBoard { GameBoard.mockEmpty(size: size) }

    // MARK: - Win

    @Test("Known 4×4 solution wins")
    func validSolutionWins() {
        var board = emptyBoard(size: 4)
        for (row, col) in [(0,1),(1,3),(2,0),(3,2)] {
            board = placeQueen(on: board, row: row, col: col)
        }
        #expect(sut.execute(board: board))
    }

    @Test("Known 5×5 solution wins")
    func anotherValidSolutionWins() {
        var board = emptyBoard(size: 5)
        for (row, col) in [(0,0),(1,2),(2,4),(3,1),(4,3)] {
            board = placeQueen(on: board, row: row, col: col)
        }
        #expect(sut.execute(board: board))
    }

    // MARK: - Not win

    @Test("Partial placement does not win")
    func partialPlacementDoesNotWin() {
        var board = emptyBoard(size: 4)
        board = placeQueen(on: board, row: 0, col: 1)
        board = placeQueen(on: board, row: 1, col: 3)
        #expect(!sut.execute(board: board))
    }

    @Test("Empty board does not win")
    func emptyBoardDoesNotWin() {
        #expect(!sut.execute(board: emptyBoard(size: 4)))
    }

    @Test("N queens with diagonal conflict does not win")
    func conflictingQueensDoNotWin() {
        var board = emptyBoard(size: 4)
        board = placeQueen(on: board, row: 0, col: 0)
        board = placeQueen(on: board, row: 1, col: 1)
        board = placeQueen(on: board, row: 2, col: 3)
        board = placeQueen(on: board, row: 3, col: 2)
        #expect(!sut.execute(board: board))
    }

    @Test("N queens all in same column does not win")
    func sameColumnQueensDoNotWin() {
        var board = emptyBoard(size: 4)
        for row in 0..<4 { board = placeQueen(on: board, row: row, col: 0) }
        #expect(!sut.execute(board: board))
    }
}
