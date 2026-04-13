import Foundation
import SwiftUI
import QueensDomain
import Combine 
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var board: GameBoard
    @Published private(set) var status: GameStatus = .playing
    @Published private(set) var elapsedSeconds: TimeInterval = 0
    /// Flips true immediately on win — drives the queen gold animation on the board.
    @Published private(set) var didWin: Bool = false
    /// Delayed — shown after the queen animation wave has played out.
    @Published var showWinModal: Bool = false
    @Published var shouldShakeCounter: Int = 0
    
    // MARK: - Dependencies

    private let validateMove: ValidateMoveUseCase
    private let checkWin: CheckWinUseCase
    private let updateStateUseCase: UpdateGameStateUseCase
    private let bestTimesUseCase: BestTimeUseCase
    private(set) var previousBestTime: BestTime?

    private var didStartPlaying = false
    
    private var timerTask: Task<Void, Never>?
    

    init(initialState: GameState,
         validateMove: ValidateMoveUseCase,
         checkWin: CheckWinUseCase,
         updateStateUseCase: UpdateGameStateUseCase,
         bestTimesUseCase: BestTimeUseCase) {
        self.board = initialState.board
        self.status = initialState.status
        self.elapsedSeconds = initialState.elapsedSeconds
        self.validateMove = validateMove
        self.checkWin = checkWin
        self.updateStateUseCase = updateStateUseCase
        self.bestTimesUseCase = bestTimesUseCase
        Task {
            self.previousBestTime = try? await bestTimesUseCase.getBest(for: board.size)
        }
    }

    // MARK: - Lifecycle

    func onAppear() {
        guard status == .playing else { return }
        startTimer()
    }

    func onDisappear() {
        stopTimer()
        persistState()
    }

    func tap(at position: Position) async {
        guard status == .playing else { return }
        didStartPlaying = true
        if shouldBlockPlacement(at: position) {
            shouldShakeCounter += 1
            return
        }
        await advanceCycle(at: position)
    }
    
    private func shouldBlockPlacement(at position: Position) -> Bool {
        let isPlacingQueen = board[position].state == .marked
        return isPlacingQueen && board.placedQueens.count >= board.size
    }

    func reset() {
        board = board.reset()
        status = .playing
        didWin = false
        showWinModal = false
        elapsedSeconds = 0
        startTimer()
        persistState()
    }

    // MARK: - Computed helpers

    var queensRemaining: Int { board.queensRemaining }
    var conflictingQueensCount: Int {
        board.allCells.filter {
            $0.state == .queen && $0.isConflict
        }.count
    }
    var formattedTime: String {
        let m = Int(elapsedSeconds) / 60
        let s = Int(elapsedSeconds) % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }

    // MARK: - Private helpers

    private func advanceCycle(at position: Position) async {
        let prevState = board[position].state
        board = board.tapping(at: position)

        // Only validate when a queen is involved.
        let newState = board[position].state
        if prevState == .queen || newState == .queen {
            board = validateMove.execute(board: board)
        }

        if newState == .queen {
            await checkForWin()
        }
    }

    private func checkForWin() async {
        guard checkWin.execute(board: board) else { return }
        status = .won
        stopTimer()
        
        await recordBestTime()
        updateStateUseCase.clear()
        didWin = true

        // 2. Delay modal until the ripple animation has finished.
        //    Max stagger = (N-1) * 0.08s + ~0.55s for the animation itself.
        let delay = Double(board.size - 1) * 0.08 + 0.85
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            self?.showWinModal = true
        }
    }

    private func recordBestTime() async {
        let record = BestTime(boardSize: board.size, seconds: elapsedSeconds)
        try? await bestTimesUseCase.save(bestTime: record)
    }

    private func persistState() {
        guard didStartPlaying else { return }
        let state = GameState(
            board: board,
            status: status,
            elapsedSeconds: elapsedSeconds,
            lastOpenedAt: Date()
        )
        updateStateUseCase.save(with: state)
    }

    // MARK: - Timer

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    self?.elapsedSeconds += 1
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
