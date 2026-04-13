import Testing
@testable import QueensDomain

@Suite("BestTimeUseCase")
struct BestTimeUseCaseTests {

    // MARK: - Helpers

    private func makeSUT() -> (sut: BestTimeUseCase, repo: MockBestTimesRepository) {
        let repo = MockBestTimesRepository()
        return (BestTimeUseCase(bestTimesRepository: repo), repo)
    }

    // MARK: - getBest

    @Test("getBest returns nil when no record exists")
    func getBestReturnsNilWhenNoRecord() async throws {
        let (sut, _) = makeSUT()
        #expect(try await sut.getBest(for: 8) == nil)
    }

    @Test("getBest returns matching size")
    func getBestReturnsMatchingSize() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedTimes = [BestTime(boardSize: 8, seconds: 45), BestTime(boardSize: 6, seconds: 30)]
        let result = try await sut.getBest(for: 8)
        #expect(result?.boardSize == 8)
        #expect(result?.seconds == 45)
    }

    @Test("getBest returns nil when size does not match")
    func getBestReturnsNilWhenSizeDoesNotMatch() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedTimes = [BestTime(boardSize: 6, seconds: 30)]
        #expect(try await sut.getBest(for: 8) == nil)
    }

    @Test("getBest returns lowest when multiple times for same size")
    func getBestReturnsLowest() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedTimes = [BestTime(boardSize: 8, seconds: 60), BestTime(boardSize: 8, seconds: 30)]
        #expect(try await sut.getBest(for: 8)?.seconds == 30)
    }

    @Test("getBest throws when repo throws")
    func getBestThrowsWhenRepoThrows() async {
        let (sut, repo) = makeSUT()
        repo.shouldThrowOnFetch = true
        await #expect(throws: (any Error).self) { try await sut.getBest(for: 8) }
    }

    // MARK: - save

    @Test("save persists to repo")
    func savePersistsToRepo() async throws {
        let (sut, repo) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 42))
        #expect(repo.savedTimes.count == 1)
        #expect(repo.savedTimes.first?.seconds == 42)
    }

    @Test("save throws when repo throws")
    func saveThrowsWhenRepoThrows() async {
        let (sut, repo) = makeSUT()
        repo.shouldThrowOnSave = true
        await #expect(throws: (any Error).self) { try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 42)) }
    }

    // MARK: - fetchAll

    @Test("fetchAll returns all stored times")
    func fetchAllReturnsAllTimes() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedTimes = [BestTime(boardSize: 4, seconds: 10), BestTime(boardSize: 8, seconds: 55)]
        #expect(try await sut.fetchAll().count == 2)
    }

    @Test("fetchAll returns empty when nothing stored")
    func fetchAllReturnsEmptyWhenNothingStored() async throws {
        let (sut, _) = makeSUT()
        #expect(try await sut.fetchAll().isEmpty)
    }

    @Test("fetchAll throws when repo throws")
    func fetchAllThrowsWhenRepoThrows() async {
        let (sut, repo) = makeSUT()
        repo.shouldThrowOnFetch = true
        await #expect(throws: (any Error).self) { try await sut.fetchAll() }
    }
}
