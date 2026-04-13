import Testing
@testable import QueensPuzzle
import QueensDomain

@Suite("GameViewModel")
@MainActor
struct GameViewModelTests {

    // MARK: - Helpers

    private func makeSUT(size: Int = 4) -> (
        sut: GameViewModel,
        bestTimesRepo: MockBestTimesRepository
    ) {
        let gameRepo      = MockGameRepository()
        let bestTimesRepo = MockBestTimesRepository()

        let sut = GameViewModel(
            initialState:     GameState(board: .mockEmpty(size: size)),
            validateMove:     ValidateMoveUseCase(),
            checkWin:         CheckWinUseCase(validateMove: ValidateMoveUseCase()),
            updateStateUseCase: UpdateGameStateUseCase(gameRepository: gameRepo),
            bestTimesUseCase: BestTimeUseCase(bestTimesRepository: bestTimesRepo)
        )
        return (sut, bestTimesRepo)
    }

    private func placeQueen(on vm: GameViewModel, row: Int, col: Int) async {
        await vm.tap(at: Position(row: row, col: col)) // → marked
        await vm.tap(at: Position(row: row, col: col)) // → queen
    }

    // MARK: - Initial state

    @Test("Board initialises with correct size")
    func boardInitialisesWithCorrectSize() {
        let (sut, _) = makeSUT(size: 6)
        #expect(sut.board.size == 6)
    }

    @Test("Timer not running before onAppear")
    func timerNotRunningBeforeOnAppear() {
        let (sut, _) = makeSUT()
        #expect(sut.elapsedSeconds == 0)
    }

    @Test("didWin starts false")
    func didWinStartsFalse() {
        let (sut, _) = makeSUT()
        #expect(sut.didWin == false)
    }

    // MARK: - Tap / cell state cycling

    @Test("Tap advances cell state empty → marked → queen → empty")
    func tapCyclesCellState() async {
        let (sut, _) = makeSUT()
        let pos = Position(row: 0, col: 0)
        #expect(sut.board[pos].state == .empty)
        await sut.tap(at: pos)
        #expect(sut.board[pos].state == .marked)
        await sut.tap(at: pos)
        #expect(sut.board[pos].state == .queen)
        await sut.tap(at: pos)
        #expect(sut.board[pos].state == .empty)
    }

    @Test("Tapping beyond queen limit shakes counter")
    func tappingBeyondLimitShakesCounter() async {
        let (sut, _) = makeSUT(size: 4)
        // Place 4 conflicting queens (all in col 0) — board stays .playing, no win
        for row in 0..<4 {
            await placeQueen(on: sut, row: row, col: 0)
        }
        let before = sut.shouldShakeCounter
        // Try to place a 5th: tap an empty cell to marked, then marked → queen is blocked
        await sut.tap(at: Position(row: 0, col: 1)) // → marked
        await sut.tap(at: Position(row: 0, col: 1)) // → blocked (count >= size) → shakes
        #expect(sut.shouldShakeCounter > before)
    }

    // MARK: - Win

    @Test("Placing known 4×4 solution triggers win")
    func placingValidSolutionTriggersWin() async {
        let (sut, _) = makeSUT(size: 4)
        for (row, col) in [(0,1),(1,3),(2,0),(3,2)] {
            await placeQueen(on: sut, row: row, col: col)
        }
        #expect(sut.didWin == true)
        #expect(sut.status == .won)
    }

    @Test("Partial placement does not trigger win")
    func partialPlacementDoesNotTriggerWin() async {
        let (sut, _) = makeSUT(size: 4)
        await placeQueen(on: sut, row: 0, col: 1)
        await placeQueen(on: sut, row: 1, col: 3)
        #expect(sut.didWin == false)
    }

    @Test("Win saves best time to repo")
    func winSavesBestTime() async throws {
        let (sut, bestTimesRepo) = makeSUT(size: 4)
        for (row, col) in [(0,1),(1,3),(2,0),(3,2)] {
            await placeQueen(on: sut, row: row, col: col)
        }
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(bestTimesRepo.savedTimes.count == 1)
        #expect(bestTimesRepo.savedTimes.first?.boardSize == 4)
    }

    // MARK: - Conflict tracking

    @Test("conflictingQueensCount is 0 on empty board")
    func conflictingQueensCountZeroOnEmpty() {
        let (sut, _) = makeSUT()
        #expect(sut.conflictingQueensCount == 0)
    }

    @Test("conflictingQueensCount increments on diagonal conflict")
    func conflictingQueensCountOnDiagonalConflict() async {
        let (sut, _) = makeSUT(size: 4)
        await placeQueen(on: sut, row: 0, col: 0)
        await placeQueen(on: sut, row: 1, col: 1)
        #expect(sut.conflictingQueensCount == 2)
    }

    // MARK: - reset

    @Test("reset clears board and resets status")
    func resetClearsBoardAndStatus() async {
        let (sut, _) = makeSUT(size: 4)
        await placeQueen(on: sut, row: 0, col: 1)
        sut.reset()
        #expect(sut.board.placedQueens.isEmpty)
        #expect(sut.status == .playing)
        #expect(sut.didWin == false)
        #expect(sut.elapsedSeconds == 0)
    }

    // MARK: - queensRemaining

    @Test("queensRemaining decrements as queens are placed")
    func queensRemainingDecrements() async {
        let (sut, _) = makeSUT(size: 4)
        #expect(sut.queensRemaining == 4)
        await placeQueen(on: sut, row: 0, col: 1)
        #expect(sut.queensRemaining == 3)
    }

    // MARK: - formattedTime

    @Test("formattedTime shows 0:00 initially")
    func formattedTimeShowsZeroInitially() {
        let (sut, _) = makeSUT()
        #expect(sut.formattedTime == "0:00")
    }
}
