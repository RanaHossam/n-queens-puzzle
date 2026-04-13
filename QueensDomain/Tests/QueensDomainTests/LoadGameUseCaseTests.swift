import XCTest
@testable import QueensDomain

final class LoadGameUseCaseTests: XCTestCase {

    private var repo: MockGameRepository!
    private var sut: LoadGameUseCase!

    override func setUp() {
        repo = MockGameRepository()
        sut = LoadGameUseCase(gameRepository: repo)
    }

    func test_returnsState_whenRepoHasOne() throws {
        let state = GameState(board: .mockEmpty(size: 4))
        repo.stubbedState = state
        let result = try sut.invoke()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.board.size, 4)
    }

    func test_returnsNil_whenRepoIsEmpty() throws {
        repo.stubbedState = nil
        let result = try sut.invoke()
        XCTAssertNil(result)
    }

    func test_propagatesThrow_whenRepoThrows() {
        repo.shouldThrowOnLoad = true
        XCTAssertThrowsError(try sut.invoke())
    }
}
