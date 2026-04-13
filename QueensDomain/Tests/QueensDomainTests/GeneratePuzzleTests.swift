import XCTest
@testable import QueensDomain

final class GeneratePuzzleTests: XCTestCase {

    private let sut = GeneratePuzzleUseCase()

    // MARK: - Board structure

    func test_generatesCorrectSize_forEachSupportedN() {
        for n in 4...15 {
            let board = sut.execute(size: n)
            XCTAssertEqual(board.size, n, "Board size mismatch for n=\(n)")
            XCTAssertEqual(board.cells.count, n)
            XCTAssertTrue(board.cells.allSatisfy { $0.count == n })
        }
    }

    // MARK: - All cells initialise empty

    func test_allCellsStartEmpty() {
        let board = sut.execute(size: 7)
        XCTAssertTrue(board.allCells.allSatisfy { $0.state == .empty && !$0.isConflict })
    }
}
