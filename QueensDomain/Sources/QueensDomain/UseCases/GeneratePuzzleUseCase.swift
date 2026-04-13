import Foundation

/// Generates a random, solvable NxN queens puzzle.
///
/// Rules enforced:
///   • Exactly one queen per row.
///   • Exactly one queen per column.
///   • No two queens on the same diagonal (main or anti).
///
/// Algorithm: backtracking row-by-row, picking columns in shuffled order.
/// For N ≤ 15 this completes in milliseconds.
public typealias BoardSize = (min: Int, max: Int)
///
public struct GeneratePuzzleUseCase {
    public init() {}

    // MARK: - Public interface
    public func execute(size: Int) -> GameBoard {
        let solution = findSolution(size: size)

        let cells: [[Cell]] = (0..<size).map { row in
            (0..<size).map { col in
                Cell(position: Position(row: row, col: col))
            }
        }

        return GameBoard(size: size, cells: cells)
    }
    
    public func getPuzzleRange() -> BoardSize {
        (4,15)
    }

    // MARK: - Backtracking placement

    private func findSolution(size: Int) -> [Position] {
        var colsUsed = Set<Int>()
        var mainDiagUsed = Set<Int>()
        var antiDiagUsed = Set<Int>()

        var queens: [Int] = []

        func canPlace(row: Int, col: Int) -> Bool {
            if colsUsed.contains(col) { return false }
            if mainDiagUsed.contains(row - col) { return false }
            if antiDiagUsed.contains(row + col) { return false }
            return true
        }

        func backtrack(row: Int) -> Bool {
            if row == size { return true }

            var cols = Array(0..<size)
            cols.shuffle()

            for col in cols {
                if canPlace(row: row, col: col) {
                    queens.append(col)
                    colsUsed.insert(col)
                    mainDiagUsed.insert(row - col)
                    antiDiagUsed.insert(row + col)

                    if backtrack(row: row + 1) { return true }

                    queens.removeLast()
                    colsUsed.remove(col)
                    mainDiagUsed.remove(row - col)
                    antiDiagUsed.remove(row + col)
                }
            }
            return false
        }

        let success = backtrack(row: 0)
        assert(success, "No solution found – should never happen for size >= 4.")

        return queens.enumerated().map { Position(row: $0.offset, col: $0.element) }
    }
}
