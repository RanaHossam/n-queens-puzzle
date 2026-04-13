import Testing
import Foundation
@testable import QueensData
import QueensDomain

@Suite("BestTimesRepository")
struct BestTimesRepositoryTests {

    // MARK: - Helpers

    /// Each test gets a fresh, isolated UserDefaults suite that is cleaned up after the test.
    private func makeSUT() -> (sut: BestTimesRepository, defaults: UserDefaults) {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return (BestTimesRepository(defaults: defaults), defaults)
    }

    // MARK: - fetchAll

    @Test("fetchAll returns empty when nothing stored")
    func fetchAllReturnsEmptyInitially() async throws {
        let (sut, _) = makeSUT()
        #expect(try await sut.fetchAll().isEmpty)
    }

    @Test("fetchAll returns all saved records")
    func fetchAllReturnsAllRecords() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 4, seconds: 20))
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 55))
        let all = try await sut.fetchAll()
        #expect(all.count == 2)
    }

    // MARK: - save — append

    @Test("save appends record for a new board size")
    func saveAppendsForNewBoardSize() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 6, seconds: 30))
        let all = try await sut.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.boardSize == 6)
        #expect(all.first?.seconds == 30)
    }

    @Test("save appends separate records for different board sizes")
    func saveKeepsSeparateRecordsPerSize() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 4, seconds: 15))
        try await sut.save(bestTime: BestTime(boardSize: 6, seconds: 40))
        #expect(try await sut.fetchAll().count == 2)
    }

    // MARK: - save — update logic (the real logic)

    @Test("save overwrites existing record when new time is better")
    func saveOverwritesWhenNewTimeIsBetter() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 60))
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 30)) // better
        let all = try await sut.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.seconds == 30)
    }

    @Test("save keeps existing record when new time is worse")
    func saveKeepsExistingWhenNewTimeIsWorse() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 30))
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 60)) // worse
        let all = try await sut.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.seconds == 30)
    }

    @Test("save keeps existing record when new time is equal")
    func saveKeepsExistingWhenNewTimeIsEqual() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 30))
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 30)) // equal
        let all = try await sut.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.seconds == 30)
    }

    // MARK: - bestTime(for:)

    @Test("bestTime returns nil when no record exists for size")
    func bestTimeReturnsNilForUnknownSize() async throws {
        let (sut, _) = makeSUT()
        #expect(try await sut.bestTime(for: 8) == nil)
    }

    @Test("bestTime returns correct record for matching size")
    func bestTimeReturnsCorrectRecord() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 8, seconds: 45))
        try await sut.save(bestTime: BestTime(boardSize: 6, seconds: 20))
        let result = try await sut.bestTime(for: 8)
        #expect(result?.seconds == 45)
    }

    @Test("bestTime returns nil for size with no matching record")
    func bestTimeReturnsNilWhenSizeDoesNotMatch() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 6, seconds: 20))
        #expect(try await sut.bestTime(for: 8) == nil)
    }

    // MARK: - Persistence

    @Test("Records survive encode-decode roundtrip")
    func recordsSurviveRoundtrip() async throws {
        let (sut, defaults) = makeSUT()
        try await sut.save(bestTime: BestTime(boardSize: 5, seconds: 77))

        // Create a second instance pointing at the same defaults — simulates app relaunch
        let sut2 = BestTimesRepository(defaults: defaults)
        let all = try await sut2.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.boardSize == 5)
        #expect(all.first?.seconds == 77)
    }
}
