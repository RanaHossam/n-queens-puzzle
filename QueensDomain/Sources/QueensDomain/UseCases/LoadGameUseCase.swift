//
//  LoadGameUseCase.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

public class LoadGameUseCase {

    private let gameRepository: GameRepositoryProtocol

    public init(gameRepository: GameRepositoryProtocol) {
        self.gameRepository = gameRepository
    }

    public func invoke() throws -> GameState? {
        try gameRepository.load()
    }
}
