//
//  ShakeEffect.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

/// A recorded best completion time for a given board size.
public struct BestTime: Codable, Sendable, Identifiable, Hashable {
    public var id: UUID
    public let boardSize: Int
    /// Elapsed seconds to solve the puzzle.
    public let seconds: TimeInterval
    public let date: Date

    public init(id: UUID = UUID(), boardSize: Int, seconds: TimeInterval, date: Date = Date()) {
        self.id = id
        self.boardSize = boardSize
        self.seconds = seconds
        self.date = date
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var formattedTime: String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }
}
