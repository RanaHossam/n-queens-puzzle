//
//  Cell.swift
//  QueensDomain
//
//  Created by Rana Hossam on 9/04/2026.
//

import Foundation

// MARK: - Cell
public struct Cell: Hashable, Codable, Sendable {
    public let position: Position
    public var state: CellState
    /// Computed by the validation use-case; not persisted as source of truth.
    public var isConflict: Bool
    
    public init(position: Position, state: CellState = .empty, isConflict: Bool = false) {
        self.position = position
        self.state = state
        self.isConflict = isConflict
    }
}

extension Cell {
    public static func mock(
        row: Int,
        col: Int,
        state: CellState = .empty,
        isConflict: Bool = false
    ) -> Cell {
        Cell(
            position: Position(row: row, col: col),
            state: state,
            isConflict: isConflict
        )
    }
}
