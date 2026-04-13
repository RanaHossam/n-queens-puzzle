import Foundation
import QueensDomain
import Combine

@MainActor
final class WinModalViewModel: ObservableObject {

    @Published private(set) var isPersonalBest: Bool = false
    @Published private(set) var previousBest: BestTime? = nil

    private let boardSize: Int
    private let elapsedSeconds: TimeInterval
    private var previousBestTime: BestTime?

    var formattedTime: String {
        let m = Int(elapsedSeconds) / 60
        let s = Int(elapsedSeconds) % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }
    init(boardSize: Int,
         elapsedSeconds: TimeInterval,
         previousBestTime: BestTime?) {
        self.boardSize = boardSize
        self.elapsedSeconds = elapsedSeconds
    }
}
