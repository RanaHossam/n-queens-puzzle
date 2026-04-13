//
//  BestTimesRepository.swift
//  QueensData
//
//  Created by Rana Hossam on 11/04/2026.
//

import Foundation
import Combine
import QueensDomain

public final class BestTimesRepository: @unchecked Sendable, BestTimesRepositoryProtocol {

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let key = "queens.bestTimes"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func save(bestTime: BestTime) async throws {
        var all = await (try? fetchAll()) ?? []
        if let existingIndex = all.firstIndex(where: { $0.boardSize == bestTime.boardSize }) {
            if bestTime.seconds < all[existingIndex].seconds {
                all[existingIndex] = bestTime
            }
        } else {
            all.append(bestTime)
        }
        let data = try encoder.encode(all)
        defaults.set(data, forKey: key)
    }

    public func fetchAll() async throws -> [BestTime] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try decoder.decode([BestTime].self, from: data)
    }

    public func bestTime(for boardSize: Int) async throws -> BestTime? {
        try await fetchAll().filter { $0.boardSize == boardSize }.min { $0.seconds < $1.seconds }
    }
}
