import Combine
import Foundation
import QueensDomain

final class MockGameRepository: GameRepositoryProtocol, @unchecked Sendable {

    var stubbedState: GameState?
    var stubbedShouldDisplayContinue: Bool = false
    var shouldThrowOnSave = false
    var shouldThrowOnLoad = false
    var shouldThrowOnClear = false

    private(set) var savedStates: [GameState] = []
    private(set) var clearCallCount = 0

    private let _stateChanged = PassthroughSubject<Void, Never>()
    var stateChanged: AnyPublisher<Void, Never> { _stateChanged.eraseToAnyPublisher() }

    func triggerStateChanged() { _stateChanged.send() }

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

final class MockBestTimesRepository: BestTimesRepositoryProtocol, @unchecked Sendable {

    var stubbedTimes: [BestTime] = []
    var shouldThrowOnSave = false
    var shouldThrowOnFetch = false

    private(set) var savedTimes: [BestTime] = []

    func save(bestTime: BestTime) async throws {
        if shouldThrowOnSave { throw MockError.bestTimeSaveFailed }
        savedTimes.append(bestTime)
        stubbedTimes.append(bestTime)
    }

    func fetchAll() async throws -> [BestTime] {
        if shouldThrowOnFetch { throw MockError.bestTimeFetchFailed }
        return stubbedTimes
    }

    func bestTime(for boardSize: Int) async throws -> BestTime? {
        if shouldThrowOnFetch { throw MockError.bestTimeFetchFailed }
        return stubbedTimes
            .filter { $0.boardSize == boardSize }
            .min(by: { $0.seconds < $1.seconds })
    }
}

enum MockError: Error {
    case saveFailed
    case loadFailed
    case clearFailed
    case bestTimeSaveFailed
    case bestTimeFetchFailed
}
