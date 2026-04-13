//
//  GameState.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

/// Top-level state managed by the game ViewModel / domain layer.
public enum GameStatus: Codable, Sendable, Equatable {
    case playing
    case won
}

public struct GameState: Codable, Sendable {
    public var board: GameBoard
    public var status: GameStatus
    /// Seconds elapsed since the puzzle was started (or resumed).
    public var elapsedSeconds: TimeInterval
    /// Wall-clock date when the user last opened / resumed this puzzle.
    public var lastOpenedAt: Date?
    
    public init(board: GameBoard,
                status: GameStatus = .playing,
                elapsedSeconds: TimeInterval = 0,
                lastOpenedAt: Date? = nil) {
        self.board = board
        self.status = status
        self.elapsedSeconds = elapsedSeconds
        self.lastOpenedAt = lastOpenedAt
    }
}
