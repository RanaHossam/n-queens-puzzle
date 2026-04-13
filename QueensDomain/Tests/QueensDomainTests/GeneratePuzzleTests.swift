import Testing
@testable import QueensDomain

@Suite("GeneratePuzzleUseCase")
struct GeneratePuzzleTests {

    private let sut = GeneratePuzzleUseCase()

    // MARK: - Board structure

    @Test("Generates correct size for each supported N", arguments: 4...15)
    func generatesCorrectSize(n: Int) {
        let board = sut.execute(size: n)
        #expect(board.size == n)
        #expect(board.cells.count == n)
        #expect(board.cells.allSatisfy { $0.count == n })
    }

    // MARK: - All cells initialise empty

    @Test("All cells start empty and conflict-free")
    func allCellsStartEmpty() {
        let board = sut.execute(size: 7)
        #expect(board.allCells.allSatisfy { $0.state == .empty && !$0.isConflict })
    }
}
