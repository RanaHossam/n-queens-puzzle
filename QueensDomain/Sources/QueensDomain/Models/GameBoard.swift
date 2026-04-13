//
//  GameBoard.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

/// The complete board model for one puzzle instance.
public struct GameBoard: Codable, Sendable {
    public let size: Int
    /// Row-major: cells[row][col]
    public var cells: [[Cell]]
    
    public init(size: Int, cells: [[Cell]]) {
        self.size = size
        self.cells = cells
    }
    
    // MARK: Subscript convenience
    public subscript(position: Position) -> Cell {
        get { cells[position.row][position.col] }
        set { cells[position.row][position.col] = newValue }
    }
    
    // MARK: Derived helpers
    public var placedQueens: [Position] {
        cells.flatMap { $0 }
            .filter { $0.state == .queen }
            .map { $0.position }
    }
    
    public var queensRemaining: Int {
        size - placedQueens.count
    }
    
    /// Returns the flat list of all cells in row-major order.
    public var allCells: [Cell] {
        cells.flatMap { $0 }
    }
    
    /// Cycle the state of the cell at `position` and return an updated board.
    public func tapping(at position: Position) -> GameBoard {
        var copy = self
        let current = copy[position].state
        let next: CellState
        switch current {
        case .empty:  next = .marked
        case .marked: next = .queen
        case .queen:  next = .empty
        }
        copy.cells[position.row][position.col].state = next
        return copy
    }
    
    /// Returns a board with all cell states reset to `.empty`.
    public func reset() -> GameBoard {
        var copy = self
        for row in 0..<size {
            for col in 0..<size {
                copy.cells[row][col].state = .empty
                copy.cells[row][col].isConflict = false
            }
        }
        return copy
    }
}

public extension GameBoard {
    static func mockEmpty(size: Int) -> GameBoard {
        let cells = (0..<size).map { row in
            (0..<size).map { col in
                Cell.mock(row: row, col: col)
            }
        }
        
        return GameBoard(
            size: size,
            cells: cells
        )
    }
}
