import Combine
import Foundation
@testable import QueensDomain

final class MockBestTimesRepository: BestTimesRepositoryProtocol, @unchecked Sendable {

    // MARK: - Configuration

    var stubbedTimes: [BestTime] = []
    var shouldThrowOnSave = false
    var shouldThrowOnFetch = false

    // MARK: - Call tracking

    private(set) var savedTimes: [BestTime] = []

    // MARK: - Publisher

    private let _timesChanged = PassthroughSubject<Void, Never>()
    var timesChanged: AnyPublisher<Void, Never> { _timesChanged.eraseToAnyPublisher() }

    // MARK: - Protocol

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
