import Testing
@testable import QueensDomain

@Suite("LoadGameUseCase")
struct LoadGameUseCaseTests {

    // MARK: - Helpers

    private func makeSUT() -> (sut: LoadGameUseCase, repo: MockGameRepository) {
        let repo = MockGameRepository()
        return (LoadGameUseCase(gameRepository: repo), repo)
    }

    // MARK: - Tests

    @Test("Returns saved state when repo has one")
    func returnsStateWhenRepoHasOne() throws {
        let (sut, repo) = makeSUT()
        repo.stubbedState = GameState(board: .mockEmpty(size: 4))
        let result = try sut.invoke()
        #expect(result != nil)
        #expect(result?.board.size == 4)
    }

    @Test("Returns nil when repo is empty")
    func returnsNilWhenRepoIsEmpty() throws {
        let (sut, _) = makeSUT()
        let result = try sut.invoke()
        #expect(result == nil)
    }

    @Test("Propagates throw when repo throws")
    func propagatesThrowWhenRepoThrows() {
        let (sut, repo) = makeSUT()
        repo.shouldThrowOnLoad = true
        #expect(throws: (any Error).self) { try sut.invoke() }
    }
}
