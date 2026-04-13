import Testing
import Combine
@testable import QueensDomain

@Suite("HasPendingGameUseCase")
struct HasPendingGameUseCaseTests {

    // MARK: - Helpers

    private func makeSUT() -> (sut: HasPendingGameUseCase, repo: MockGameRepository) {
        let repo = MockGameRepository()
        return (HasPendingGameUseCase(gameRepository: repo), repo)
    }

    // MARK: - Tests

    @Test("Returns true when repo should display continue")
    func returnsTrueWhenRepoDoesContinue() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedShouldDisplayContinue = true
        #expect(try await sut.invoke() == true)
    }

    @Test("Returns false when repo should not display continue")
    func returnsFalseWhenRepoDoesNotContinue() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedShouldDisplayContinue = false
        #expect(try await sut.invoke() == false)
    }

    @Test("stateChanged forwards repo publisher")
    func stateChangedForwardsRepoPublisher() async {
        let (sut, repo) = makeSUT()
        var cancellables = Set<AnyCancellable>()

        await confirmation("stateChanged fires") { confirm in
            sut.stateChanged
                .sink { confirm() }
                .store(in: &cancellables)
            repo.triggerStateChanged()
        }
    }
}
