import XCTest
@testable import QueensDomain

final class BestTimeUseCaseTests: XCTestCase {

    private var repo: MockBestTimesRepository!
    private var sut: BestTimeUseCase!

    override func setUp() {
        repo = MockBestTimesRepository()
        sut = BestTimeUseCase(bestTimesRepository: repo)
    }

    // MARK: - getBest

    func test_getBest_returnsNil_whenNoRecordExists() async throws {
        let result = try await sut.getBest(for: 8)
        XCTAssertNil(result)
    }

    func test_getBest_returnsBestTime_forMatchingSize() async throws {
        repo.stubbedTimes = [
            BestTime(boardSize: 8, seconds: 45),
            BestTime(boardSize: 6, seconds: 30)
        ]
        let result = try await sut.getBest(for: 8)
        XCTAssertEqual(result?.boardSize, 8)
        XCTAssertEqual(result?.seconds, 45)
    }

    func test_getBest_returnsNil_whenSizeDoesNotMatch() async throws {
        repo.stubbedTimes = [BestTime(boardSize: 6, seconds: 30)]
        let result = try await sut.getBest(for: 8)
        XCTAssertNil(result)
    }

    func test_getBest_returnsLowest_whenMultipleTimesForSameSize() async throws {
        repo.stubbedTimes = [
            BestTime(boardSize: 8, seconds: 60),
            BestTime(boardSize: 8, seconds: 30)
        ]
        let result = try await sut.getBest(for: 8)
        XCTAssertEqual(result?.seconds, 30)
    }

    func test_getBest_throwsWhenRepoThrows() async {
        repo.shouldThrowOnFetch = true
        await XCTAssertThrowsErrorAsync(try await sut.getBest(for: 8))
    }

    // MARK: - save

    func test_save_persistsToRepo() async throws {
        let record = BestTime(boardSize: 8, seconds: 42)
        try await sut.save(bestTime: record)
        XCTAssertEqual(repo.savedTimes.count, 1)
        XCTAssertEqual(repo.savedTimes.first?.seconds, 42)
    }

    func test_save_throwsWhenRepoThrows() async {
        repo.shouldThrowOnSave = true
        let record = BestTime(boardSize: 8, seconds: 42)
        await XCTAssertThrowsErrorAsync(try await sut.save(bestTime: record))
    }

    // MARK: - fetchAll

    func test_fetchAll_returnsAllStoredTimes() async throws {
        repo.stubbedTimes = [
            BestTime(boardSize: 4, seconds: 10),
            BestTime(boardSize: 8, seconds: 55)
        ]
        let result = try await sut.fetchAll()
        XCTAssertEqual(result.count, 2)
    }

    func test_fetchAll_returnsEmpty_whenNoTimesStored() async throws {
        let result = try await sut.fetchAll()
        XCTAssertTrue(result.isEmpty)
    }

    func test_fetchAll_throwsWhenRepoThrows() async {
        repo.shouldThrowOnFetch = true
        await XCTAssertThrowsErrorAsync(try await sut.fetchAll())
    }
}

// MARK: - Async throw helper

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown", file: file, line: line)
    } catch {}
}
