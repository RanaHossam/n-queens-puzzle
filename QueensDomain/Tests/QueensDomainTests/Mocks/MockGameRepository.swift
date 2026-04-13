import Combine
import Foundation
@testable import QueensDomain

final class MockGameRepository: GameRepositoryProtocol, @unchecked Sendable {

    // MARK: - Configuration

    var stubbedState: GameState?
    var stubbedShouldDisplayContinue: Bool = false
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    var shouldThrowOnClear = false

    // MARK: - Call tracking

    private(set) var savedStates: [GameState] = []
    private(set) var clearCallCount = 0

    // MARK: - Publisher

    private let _stateChanged = PassthroughSubject<Void, Never>()
    var stateChanged: AnyPublisher<Void, Never> { _stateChanged.eraseToAnyPublisher() }

    func triggerStateChanged() { _stateChanged.send() }

    // MARK: - Protocol

    func save(state: GameState) throws {
        if shouldThrowOnSave { throw MockError.saveFailed }
        savedStates.append(state)
    }

    func load() throws -> GameState? {
        if shouldThrowOnLoad { throw MockError.loadFailed }
        return stubbedState
    }

    func clear() throws {
        if shouldThrowOnClear { throw MockError.clearFailed }
        clearCallCount += 1
        stubbedState = nil
    }

    func shouldDisplayContinue() async throws -> Bool {
        stubbedShouldDisplayContinue
    }
}

enum MockError: Error {
    case saveFailed
    case loadFailed
    case clearFailed
    case bestTimeSaveFailed
    case bestTimeFetchFailed
}
