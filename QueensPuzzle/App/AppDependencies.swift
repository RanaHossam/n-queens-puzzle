import Foundation
import QueensDomain
import QueensData

/// Single composition-root object that owns all shared dependencies.
/// Injected into the environment so ViewModels can be initialised without singletons.
@MainActor
struct AppDependencies {
    
    let gameRepository: any GameRepositoryProtocol
    let generatePuzzle: GeneratePuzzleUseCase
    let validateMove: ValidateMoveUseCase
    let checkWin: CheckWinUseCase
    let bestTimesUseCase: BestTimeUseCase
    let updateStateUseCase: UpdateGameStateUseCase
    let hasPendingGameUseCase: HasPendingGameUseCase
    let loadGameUseCase: LoadGameUseCase

    init() {
        let gameRepo = GameRepository()
        let bestTimesRepo = BestTimesRepository()
        gameRepository = gameRepo
        generatePuzzle = GeneratePuzzleUseCase()
        validateMove = ValidateMoveUseCase()
        checkWin = CheckWinUseCase(validateMove: validateMove)
        loadGameUseCase = LoadGameUseCase(gameRepository: gameRepo)
        bestTimesUseCase = BestTimeUseCase(bestTimesRepository: bestTimesRepo)
        updateStateUseCase = UpdateGameStateUseCase(gameRepository: gameRepository)
        hasPendingGameUseCase = HasPendingGameUseCase(gameRepository: gameRepo)
    }
}

extension AppDependencies {
    static let `default`: AppDependencies  = AppDependencies()
}

// Knights attack in L shape, N * N
// Lshaped move 1 sq in a direction and 2 sqaures in the perpendicular directions
