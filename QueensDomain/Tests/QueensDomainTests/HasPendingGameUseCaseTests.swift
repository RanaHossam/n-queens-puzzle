import XCTest
import Combine
@testable import QueensDomain

final class HasPendingGameUseCaseTests: XCTestCase {

    private var repo: MockGameRepository!
    private var sut: HasPendingGameUseCase!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        repo = MockGameRepository()
        sut = HasPendingGameUseCase(gameRepository: repo)
    }

    func test_returnsTrue_whenRepoDoesContinue() async throws {
        repo.stubbedShouldDisplayContinue = true
        let result = try await sut.invoke()
        XCTAssertTrue(result)
    }

    func test_returnsFalse_whenRepoDoesNotContinue() async throws {
        repo.stubbedShouldDisplayContinue = false
        let result = try await sut.invoke()
        XCTAssertFalse(result)
    }

    func test_stateChanged_forwardsRepoPublisher() {
        let expectation = expectation(description: "stateChanged fires")
        sut.stateChanged
            .sink { expectation.fulfill() }
            .store(in: &cancellables)
        repo.triggerStateChanged()
        wait(for: [expectation], timeout: 1)
    }
}
