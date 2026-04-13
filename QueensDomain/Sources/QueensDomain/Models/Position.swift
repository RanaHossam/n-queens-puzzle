//
//  Position.swift
//  QueensDomain
//
//  Created by Rana Hossam on 13/04/2026.
//

/// The (row, col) coordinate of a cell on the board. Zero-indexed.
public struct Position: Hashable, Codable, Sendable {
    public let row: Int
    public let col: Int
    
    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    public func conflicts(with other: Position) -> Bool {
        return row == other.row ||
                   col == other.col ||
                   abs(row - other.row) == abs(col - other.col)
    }
}
