# NxN Queens – Architecture Reference

## Dependency graph

```
QueensPuzzle (app)  →  QueensDomain  (models, use-cases, protocols)
QueensPuzzle (app)  →  QueensData    (concrete repositories)
QueensData          →  QueensDomain
```

- **QueensDomain** has zero external dependencies.
- **QueensData** depends only on QueensDomain.
- **QueensPuzzle** depends on both packages.

---

## QueensDomain (Swift Package)

### Models

| File | Purpose |
|------|---------|
| `Models/Position.swift` | Zero-indexed `(row, col)` coordinate; `conflicts(with:)` checks row, column, and full diagonal |
| `Models/CellState.swift` | `empty` / `marked` / `queen` tap-cycle states |
| `Models/Cell.swift` | A single board cell: position, state, `isConflict` flag (computed by validation, not persisted as source of truth) |
| `Models/GameBoard.swift` | N×N grid (row-major `[[Cell]]`); `tapping(at:)` cycles state, `reset()` clears all cells |
| `Models/GameState.swift` | Wraps `GameBoard` + `GameStatus` + elapsed seconds + last-opened date for persistence |
| `Models/BestTime.swift` | Per-size personal best: board size, elapsed seconds, date |

### Protocols

| File | Purpose |
|------|---------|
| `Protocols/GameRepositoryProtocol.swift` | `save` / `load` / `clear` in-progress game; `shouldDisplayContinue()` async query; `stateChanged` publisher |
| `Protocols/BestTimesRepositoryProtocol.swift` | `save` / `fetchAll` / `bestTime(for:)` — no publisher (home refreshes on `onAppear`) |

### Use Cases

| File | Purpose |
|------|---------|
| `UseCases/GeneratePuzzleUseCase.swift` | Randomised backtracking solver (row-by-row, columns shuffled). O(N!) worst case, completes in milliseconds for N≤15. Returns an empty `GameBoard` — solution is not stored. |
| `UseCases/ValidateMoveUseCase.swift` | Pure function. Scans all placed queens for row, column, or diagonal conflicts; sets `isConflict` on affected cells. Called on every queen placement or removal. |
| `UseCases/CheckWinUseCase.swift` | Pure query. Returns `true` when N queens are placed and `ValidateMoveUseCase` finds zero conflicts. No side effects. |
| `UseCases/LoadGameUseCase.swift` | Thin wrapper: calls `gameRepository.load()`. |
| `UseCases/UpdateGameStateUseCase.swift` | `save(with:)` persists state; `clear()` removes it. Both swallow errors with `try?`. |
| `UseCases/HasPendingGameUseCase.swift` | `invoke()` delegates to `gameRepository.shouldDisplayContinue()`; forwards `stateChanged` publisher. |
| `UseCases/BestTimeUseCase.swift` | `getBest(for:)`, `save(bestTime:)`, `fetchAll()` — delegates to `BestTimesRepositoryProtocol`. |

### Game rules encoded in domain

- One queen per **row** — enforced by backtracking row-by-row in `GeneratePuzzleUseCase`
- One queen per **column** — tracked via `colsUsed` set during generation; checked in `ValidateMoveUseCase`
- No two queens on the same **diagonal** — `row - col` (main) and `row + col` (anti) sets during generation; `abs(row-row) == abs(col-col)` in `Position.conflicts(with:)`

### Tap cycle

```
empty  →  marked (✕)  →  queen (♛)  →  empty
```

After each queen placement `ValidateMoveUseCase` runs and marks conflicts. After the Nth queen `CheckWinUseCase` checks for a win.

---

## QueensData (Swift Package)

| File | Purpose |
|------|---------|
| `Repositories/GameRepository.swift` | `UserDefaults` + `JSONEncoder/Decoder`; fires `stateChanged` publisher on `save` and `clear` |
| `Repositories/BestTimesRepository.swift` | `UserDefaults` + JSON; **only overwrites** an existing record when the new time is strictly better |

---

## QueensPuzzle (Xcode target)

### App

| File | Purpose |
|------|---------|
| `App/QueensGameApp.swift` | `@main`; creates `AppDependencies` and `ThemeStore`; injects both into the SwiftUI environment |
| `App/AppDependencies.swift` | Composition root. Owns all repository and use-case instances. Exposed via `@Entry var dependenciesContainer` environment key. |

### Resources

| File | Purpose |
|------|---------|
| `Resources/AppTheme.swift` | `AppTheme` struct (injectable via `\.appTheme` environment key); `ThemeStore` (`@Observable`) persists selected theme to `UserDefaults`; `Spacing`, `Radius`, and `Typography` static namespaces for design tokens |
| `Resources/L10n.swift` | Static `String(localized:)` wrappers for all user-visible strings; backed by `Localizable.xcstrings` (English + Arabic) |

### Presentation / Home

| File | Purpose |
|------|---------|
| `Home/HomeViewModel.swift` | Refreshes `hasSavedGame` and `bestTimes` on `onAppear`; creates new `GameState` via `GeneratePuzzleUseCase`; pushes navigation routes via `Router` |
| `Home/Views/HomeView.swift` | Crown header, continue button (when saved game exists), size-tile grid (4–15), best times list |
| `Home/Views/SizeTileView.swift` | Single tappable tile showing board size and personal best |

### Presentation / Game

| File | Purpose |
|------|---------|
| `Game/GameViewModel.swift` | Owns the async timer `Task`; calls `ValidateMoveUseCase` on every queen change; calls `CheckWinUseCase` after each queen placed; persists via `UpdateGameStateUseCase` on disappear; clears on win |
| `Game/Views/GameView.swift` | Top bar (timer + queen counter + reset button), `BoardView`, win sheet |
| `Game/Views/BoardView.swift` | `Canvas` for grid lines and rounded-rect border (turns gold on win); `VStack/HStack` overlay of interactive `CellView`s; ripple win-animation delay via Chebyshev distance |
| `Game/Views/CellView.swift` | Renders empty / ✕ / queen states; spring animation on placement; switches to gold gradient crown on win |
| `Game/Views/QueensCounterView.swift` | Crown icon + placed/total fraction + capsule progress bar; shakes on blocked placement |
| `Game/Views/ShakeEffect.swift` | `GeometryEffect` producing a horizontal shake animation |

### Presentation / Settings

| File | Purpose |
|------|---------|
| `Settings/SettingsViewModel.swift` | Placeholder; no logic currently |
| `Settings/Views/SettingsView.swift` | Theme picker (swatch grid) and language row (deep-links to iOS Settings) |
| `Settings/Views/ThemeSwatch.swift` | Single gradient swatch with selected-state ring and checkmark |

### Presentation / Win

| File | Purpose |
|------|---------|
| `Win/WinModalViewModel.swift` | Computes formatted time and personal-best comparison against previous record |
| `Win/Views/WinModal.swift` | Animated gold crown entrance, time label, personal-best badge, done button |
| `Win/Views/ConfettiView.swift` | `TimelineView` + `Canvas` confetti with gravity simulation; particles spawned on `onAppear` |
| `Win/Models/ConfettiParticle.swift` | Value type holding per-particle physics state |

### Navigation

| File | Purpose |
|------|---------|
| `Presentation/Router.swift` | `ObservableObject` wrapping `NavigationStack` path; `push(route:)` / `pop()` |
| `Presentation/Routes.swift` | `NavigationRoute` enum: `.newGame(GameState)`, `.resume(GameState)`, `.settings`; `SheetRoute` enum |

---

## Theme system

`AppTheme` is a lightweight struct injected via `\.appTheme` environment key. It carries a `Colors` sub-struct (cell shades, queen gold gradient, conflict colour, accent) used by every view. Three built-in themes are defined: **Classic**, **Ocean**, **Amethyst**. `ThemeStore` (`@Observable`) persists the selected theme ID to `UserDefaults` and resolves the active `AppTheme`.

Design tokens live in static enums alongside `AppTheme`:

| Enum | Tokens |
|------|--------|
| `Spacing` | `xs(4)` `sm(8)` `md(12)` `lg(16)` `xl(24)` `xxl(32)` |
| `Radius` | `sm(8)` `md(12)` `lg(14)` |
| `Typography` | `largeTitle` `title2` `title3Bold` `headline` `headlineMono` `subheadline` `subheadlineBold` `caption2` |

---

## Localisation

All user-visible strings go through `L10n` (static wrappers over `String(localized:)`), backed by `Localizable.xcstrings`. Two locales are fully translated: **English** and **Arabic**.

---

## Testing

### QueensDomainTests (Swift Testing)

| Suite | What it covers |
|-------|---------------|
| `GeneratePuzzleTests` | Board size correctness; all cells start empty |
| `ValidateMoveTests` | Row / column / diagonal conflicts; win detection; tap cycle; reset |
| `CheckWinUseCaseTests` | Valid solutions win; partial / conflicting placements do not |
| `LoadGameUseCaseTests` | Returns state, nil, and propagates throws |
| `HasPendingGameUseCaseTests` | Boolean delegation; `stateChanged` publisher forwarding |
| `BestTimeUseCaseTests` | `getBest` / `save` / `fetchAll` including throw paths |
| `UpdateGameStateUseCaseTests` | `save` and `clear` including silent-error behaviour |

Mocks (`MockGameRepository`, `MockBestTimesRepository`) live in `Tests/QueensDomainTests/Mocks/`.

### QueensDataTests (Swift Testing)

| Suite | What it covers |
|-------|---------------|
| `BestTimesRepositoryTests` | Append / overwrite-if-better / keep-if-worse logic; `bestTime(for:)` lookup; encode-decode roundtrip across two repository instances |

Each test uses a fresh `UserDefaults(suiteName: UUID().uuidString)` to stay fully isolated.

### QueensPuzzleTests (Swift Testing)

| Suite | What it covers |
|-------|---------------|
| `HomeViewModelTests` | `onAppear` refresh, `startNewGame` routing and confirmation guard, `confirmNewGame`, `continueGame`, `bestTime(for:)`, puzzle range |
| `GameViewModelTests` | Initial state, tap cycle, queen-limit shake, win detection, best-time persistence on win, conflict count, reset, `queensRemaining`, `formattedTime` |
| `SettingsViewModelTests` | Smoke test |

Mocks (`MockGameRepository`, `MockBestTimesRepository`, `MockRouter`) live in `QueensPuzzleTests/Mocks/`.
