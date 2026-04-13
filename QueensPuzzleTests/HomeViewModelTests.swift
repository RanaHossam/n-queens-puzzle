import Testing
import Combine
@testable import QueensPuzzle
import QueensDomain

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: HomeViewModel,
        gameRepo: MockGameRepository,
        bestTimesRepo: MockBestTimesRepository,
        router: MockRouter
    ) {
        let gameRepo      = MockGameRepository()
        let bestTimesRepo = MockBestTimesRepository()
        let router        = MockRouter()

        let sut = HomeViewModel(
            loadGameUseCase:      LoadGameUseCase(gameRepository: gameRepo),
            hasPendingGameUseCase: HasPendingGameUseCase(gameRepository: gameRepo),
            bestTimeUseCase:      BestTimeUseCase(bestTimesRepository: bestTimesRepo),
            updateStateUseCase:   UpdateGameStateUseCase(gameRepository: gameRepo),
            generatePuzzle:       GeneratePuzzleUseCase(),
            router:               router
        )
        return (sut, gameRepo, bestTimesRepo, router)
    }

    // MARK: - onAppear

    @Test("onAppear sets hasSavedGame true when repo has a pending game")
    func onAppearSetsSavedGameTrue() async throws {
        let (sut, gameRepo, _, _) = makeSUT()
        gameRepo.stubbedShouldDisplayContinue = true
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.hasSavedGame == true)
    }

    @Test("onAppear sets hasSavedGame false when repo has no pending game")
    func onAppearSetsSavedGameFalse() async throws {
        let (sut, gameRepo, _, _) = makeSUT()
        gameRepo.stubbedShouldDisplayContinue = false
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.hasSavedGame == false)
    }

    @Test("onAppear loads best times from repo")
    func onAppearLoadsBestTimes() async throws {
        let (sut, _, bestTimesRepo, _) = makeSUT()
        bestTimesRepo.stubbedTimes = [BestTime(boardSize: 6, seconds: 30)]
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.bestTimes.count == 1)
    }

    // MARK: - startNewGame

    @Test("startNewGame pushes newGame route when no saved game")
    func startNewGamePushesRoute() async throws {
        let (sut, gameRepo, _, router) = makeSUT()
        gameRepo.stubbedShouldDisplayContinue = false
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.startNewGame(size: 6)
        #expect(router.pushedRoutes.count == 1)
        #expect(router.pushedRoutes.first?.id == "new")
    }

    @Test("startNewGame shows confirmation when saved game exists")
    func startNewGameShowsConfirmationWhenSavedGameExists() async throws {
        let (sut, gameRepo, _, _) = makeSUT()
        gameRepo.stubbedShouldDisplayContinue = true
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.startNewGame(size: 6)
        #expect(sut.showingConfirmation == true)
    }

    // MARK: - confirmNewGame

    @Test("confirmNewGame clears old game and pushes new route")
    func confirmNewGameClearsAndPushes() async throws {
        let (sut, gameRepo, _, router) = makeSUT()
        gameRepo.stubbedShouldDisplayContinue = true
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        sut.startNewGame(size: 8)
        sut.confirmNewGame()
        #expect(gameRepo.clearCallCount == 1)
        #expect(router.pushedRoutes.count == 1)
        #expect(router.pushedRoutes.first?.id == "new")
    }

    // MARK: - continueGame

    @Test("continueGame pushes resume route with saved state")
    func continueGamePushesResumeRoute() async throws {
        let (sut, gameRepo, _, router) = makeSUT()
        gameRepo.stubbedState = GameState(board: .mockEmpty(size: 5))
        sut.continueGame()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(router.pushedRoutes.count == 1)
        #expect(router.pushedRoutes.first?.id == "resume")
    }

    // MARK: - bestTime(for:)

    @Test("bestTime returns correct record for size")
    func bestTimeReturnsCorrectRecord() async throws {
        let (sut, _, bestTimesRepo, _) = makeSUT()
        bestTimesRepo.stubbedTimes = [BestTime(boardSize: 8, seconds: 42)]
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.bestTime(for: 8)?.seconds == 42)
    }

    @Test("bestTime returns nil when no record for size")
    func bestTimeReturnsNilForUnknownSize() async throws {
        let (sut, _, _, _) = makeSUT()
        sut.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.bestTime(for: 8) == nil)
    }

    // MARK: - Puzzle range

    @Test("getPuzzleMin returns 4")
    func getPuzzleMinReturns4() {
        let (sut, _, _, _) = makeSUT()
        #expect(sut.getPuzzleMin() == 4)
    }

    @Test("getPuzzleMax returns 15")
    func getPuzzleMaxReturns15() {
        let (sut, _, _, _) = makeSUT()
        #expect(sut.getPuzzleMax() == 15)
    }
}
