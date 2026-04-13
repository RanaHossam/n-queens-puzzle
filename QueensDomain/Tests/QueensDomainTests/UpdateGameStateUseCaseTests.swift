import Testing
@testable import QueensDomain

@Suite("UpdateGameStateUseCase")
struct UpdateGameStateUseCaseTests {

    // MARK: - Helpers

    private func makeSUT() -> (sut: UpdateGameStateUseCase, repo: MockGameRepository) {
        let repo = MockGameRepository()
        return (UpdateGameStateUseCase(gameRepository: repo), repo)
    }

    // MARK: - save

    @Test("save persists state to repo")
    func savePersistsState() {
        let (sut, repo) = makeSUT()
        sut.save(with: GameState(board: .mockEmpty(size: 6), elapsedSeconds: 30))
        #expect(repo.savedStates.count == 1)
        #expect(repo.savedStates.first?.elapsedSeconds == 30)
        #expect(repo.savedStates.first?.board.size == 6)
    }

    @Test("save silently ignores repo error")
    func saveSilentlyIgnoresError() {
        let (sut, repo) = makeSUT()
        repo.shouldThrowOnSave = true
        sut.save(with: GameState(board: .mockEmpty(size: 4)))
        #expect(repo.savedStates.isEmpty)
    }

    @Test("save can be called multiple times")
    func saveCanBeCalledMultipleTimes() {
        let (sut, repo) = makeSUT()
        sut.save(with: GameState(board: .mockEmpty(size: 4)))
        sut.save(with: GameState(board: .mockEmpty(size: 6)))
        #expect(repo.savedStates.count == 2)
    }

    // MARK: - clear

    @Test("clear calls repo once")
    func clearCallsRepoOnce() {
        let (sut, repo) = makeSUT()
        sut.clear()
        #expect(repo.clearCallCount == 1)
    }

    @Test("clear nils out stored state")
    func clearNilsOutStoredState() {
        let (sut, repo) = makeSUT()
        repo.stubbedState = GameState(board: .mockEmpty(size: 4))
        sut.clear()
        #expect(repo.stubbedState == nil)
    }

    @Test("clear silently ignores repo error")
    func clearSilentlyIgnoresError() {
        let (sut, repo) = makeSUT()
        repo.shouldThrowOnClear = true
        sut.clear()
        #expect(repo.clearCallCount == 0)
    }
}
