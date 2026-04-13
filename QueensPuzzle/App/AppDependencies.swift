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
    let router: Router
    let homeViewModel: HomeViewModel

    init() {
        let gameRepo = GameRepository()
        let bestTimesRepo = BestTimesRepository()

        gameRepository = gameRepo
        generatePuzzle = GeneratePuzzleUseCase()
        validateMove = ValidateMoveUseCase()
        checkWin = CheckWinUseCase(validateMove: validateMove)
        bestTimesUseCase = BestTimeUseCase(bestTimesRepository: bestTimesRepo)
        updateStateUseCase = UpdateGameStateUseCase(gameRepository: gameRepository)
        router = Router()
        homeViewModel = HomeViewModel(
            loadGameUseCase: LoadGameUseCase(gameRepository: gameRepo),
            hasPendingGameUseCase: HasPendingGameUseCase(gameRepository: gameRepo),
            bestTimeUseCase: bestTimesUseCase,
            updateStateUseCase: updateStateUseCase,
            generatePuzzle: generatePuzzle,
            router: router
        )
    }
}

// TODO for tests, inject repos in the init to handle tests
extension AppDependencies {
    static let mock: AppDependencies  = AppDependencies() // todo replace with mock dependencies
}

