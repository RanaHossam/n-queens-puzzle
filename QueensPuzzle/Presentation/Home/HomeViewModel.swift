import Foundation
import QueensDomain
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published state
    @Published var hasSavedGame: Bool = false
    @Published var bestTimes: [BestTime] = []
    @Published var showingConfirmation = false
    
    // MARK: - Dependencies
    private let loadGameUseCase: LoadGameUseCase
    private let hasPendingGameUseCase: HasPendingGameUseCase
    private let bestTimeUseCase: BestTimeUseCase
    private let updateStateUseCase: UpdateGameStateUseCase
    private let generatePuzzle: GeneratePuzzleUseCase
    private let router: Router
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - State
    private var selectedSize: Int?
    
    init(loadGameUseCase: LoadGameUseCase,
         hasPendingGameUseCase: HasPendingGameUseCase,
         bestTimeUseCase: BestTimeUseCase,
         updateStateUseCase: UpdateGameStateUseCase,
         generatePuzzle: GeneratePuzzleUseCase,
         router: Router) {
        self.loadGameUseCase = loadGameUseCase
        self.hasPendingGameUseCase = hasPendingGameUseCase
        self.bestTimeUseCase = bestTimeUseCase
        self.updateStateUseCase = updateStateUseCase
        self.generatePuzzle = generatePuzzle
        self.router = router
        setupObservers()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func onAppear() {
        Task {
            await refreshState()
        }
    }
    
    func confirmNewGame() {
        guard let selectedSize else { return }
        updateStateUseCase.clear()
        let board = generatePuzzle.execute(size: selectedSize)
        let state = GameState(board: board, lastOpenedAt: Date())
        router.push(route: .newGame(state))
    }
    
    func startNewGame(size: Int) {
        selectedSize = size
        if hasSavedGame {
            showingConfirmation = true
        } else {
            let board = generatePuzzle.execute(size: size)
            let state = GameState(board: board, lastOpenedAt: Date())
            router.push(route: .newGame(state))
        }
    }
    
    func getPuzzleMin() -> Int {
        generatePuzzle.getPuzzleRange().min
    }
    
    func getPuzzleMax() -> Int {
        generatePuzzle.getPuzzleRange().max
    }
    
    func continueGame() {
        Task {
            guard let state = try? loadGameUseCase.invoke() else { return }
            router.push(route: .resume(state))
        }
    }
    
    func bestTime(for size: Int) -> BestTime? {
        return bestTimes.first { $0.boardSize == size }
    }
    
    private func refreshState() async {
        hasSavedGame = (try? await hasPendingGameUseCase.invoke()) ?? false
        let result = (try? await bestTimeUseCase.fetchAll()) ?? []
        bestTimes = result
    }
    
    private func setupObservers() {
        hasPendingGameUseCase.stateChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                Task {
                    await self?.refreshState()
                }
            }
            .store(in: &cancellables)
    }
}
