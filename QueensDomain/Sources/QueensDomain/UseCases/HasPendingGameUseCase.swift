//
//  HasPendingGameUseCase.swift
//  QueensDomain
//
//  Created by Rana Hossam on 12/04/2026.
//

import Combine

public class HasPendingGameUseCase {
    
    private let gameRepository: GameRepositoryProtocol

    public init(gameRepository: GameRepositoryProtocol) {
        self.gameRepository = gameRepository
    }
    
    public var stateChanged: AnyPublisher<Void, Never> {
        gameRepository.stateChanged
    }

    public func invoke() async throws -> Bool {
        return try await gameRepository.shouldDisplayContinue()
    }
}
