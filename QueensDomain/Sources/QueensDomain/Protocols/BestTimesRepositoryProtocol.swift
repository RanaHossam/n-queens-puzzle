//
//  BestTimesRepositoryProtocol.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation
import Combine

public protocol BestTimesRepositoryProtocol: Sendable {
    func save(bestTime: BestTime) async throws
    func fetchAll() async throws -> [BestTime]
    func bestTime(for boardSize: Int) async throws -> BestTime?
}
