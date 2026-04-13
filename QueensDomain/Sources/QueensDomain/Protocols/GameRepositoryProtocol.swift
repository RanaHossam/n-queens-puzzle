//
//  GameRepositoryProtocol.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation
import Combine

/// Contract for persisting / restoring an in-progress game.
public protocol GameRepositoryProtocol: Sendable {
    var stateChanged: AnyPublisher<Void, Never> { get }
    func save(state: GameState) throws
    func load() throws -> GameState?
    func clear() throws
    func shouldDisplayContinue() async throws -> Bool
}
