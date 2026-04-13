
//
//  BestTimesRepository.swift
//  QueensData
//
//  Created by Rana Hossam on 11/04/2026.
//

import Foundation
import Combine
import QueensDomain

/// Persists the in-progress game state using UserDefaults + JSON.
public final class GameRepository: @unchecked Sendable, GameRepositoryProtocol {

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let key = "queens.savedGame"

    private let _stateChanged = PassthroughSubject<Void, Never>()
    public var stateChanged: AnyPublisher<Void, Never> {
        _stateChanged.eraseToAnyPublisher()
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func save(state: GameState) throws {
        let data = try encoder.encode(state)
        defaults.set(data, forKey: key)
        _stateChanged.send()
    }

    public func load() throws -> GameState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try decoder.decode(GameState.self, from: data)
    }

    public func clear() throws {
        defaults.removeObject(forKey: key)
        _stateChanged.send()
    }
    
    public func shouldDisplayContinue() async throws -> Bool {
        guard let data = defaults.data(forKey: key) else { return false }
        return try decoder.decode(GameState.self, from: data).status == .playing
    }
}
