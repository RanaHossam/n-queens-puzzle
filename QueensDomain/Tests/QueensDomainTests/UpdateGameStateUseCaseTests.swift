import XCTest
@testable import QueensDomain

final class UpdateGameStateUseCaseTests: XCTestCase {

    private var repo: MockGameRepository!
    private var sut: UpdateGameStateUseCase!

    override func setUp() {
        repo = MockGameRepository()
        sut = UpdateGameStateUseCase(gameRepository: repo)
    }

    // MARK: - save

    func test_save_persistsStateToRepo() {
        let state = GameState(board: .mockEmpty(size: 6), elapsedSeconds: 30)
        sut.save(with: state)
        XCTAssertEqual(repo.savedStates.count, 1)
        XCTAssertEqual(repo.savedStates.first?.elapsedSeconds, 30)
        XCTAssertEqual(repo.savedStates.first?.board.size, 6)
    }

    func test_save_silentlyIgnoresRepoError() {
        repo.shouldThrowOnSave = true
        let state = GameState(board: .mockEmpty(size: 4))
        // Must not crash — UpdateGameStateUseCase uses try?
        sut.save(with: state)
        XCTAssertTrue(repo.savedStates.isEmpty)
    }

    func test_save_canBeCalledMultipleTimes() {
        sut.save(with: GameState(board: .mockEmpty(size: 4)))
        sut.save(with: GameState(board: .mockEmpty(size: 6)))
        XCTAssertEqual(repo.savedStates.count, 2)
    }

    // MARK: - clear

    func test_clear_callsRepoOnce() {
        sut.clear()
        XCTAssertEqual(repo.clearCallCount, 1)
    }

    func test_clear_nilsOutStoredState() {
        repo.stubbedState = GameState(board: .mockEmpty(size: 4))
        sut.clear()
        XCTAssertNil(repo.stubbedState)
    }

    func test_clear_silentlyIgnoresRepoError() {
        repo.shouldThrowOnClear = true
        // Must not crash
        sut.clear()
        XCTAssertEqual(repo.clearCallCount, 0)
    }
}
