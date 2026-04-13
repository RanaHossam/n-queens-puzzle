//
//  UpdateGameStateUseCase.swift
//  QueensDomain
//
//  Created by Rana Hossam on 13/04/2026.
//

import Foundation

public class UpdateGameStateUseCase {

    private let gameRepository: GameRepositoryProtocol

    public init(gameRepository: GameRepositoryProtocol) {
        self.gameRepository = gameRepository
    }

    public func save(with state: GameState) {
        try? gameRepository.save(state: state)
    }
    
    public func clear() {
        try? gameRepository.clear()
    }
    
}
