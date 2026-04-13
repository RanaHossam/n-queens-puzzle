# NxN Queens – Architecture Reference

## Dependency graph

```
QueensApp  →  QueensDomain  (models, use cases, protocols)
QueensApp  →  QueensData    (concrete repositories)
QueensData →  QueensDomain
```

QueensDomain has **zero** external dependencies.
QueensData depends only on QueensDomain.
QueensApp depends on both packages.

---

## QueensDomain (Swift Package)

| File | Purpose |
|------|---------|
| `Models/Cell.swift` | `Position`, `CellState` enum, `Cell` struct |
| `Models/GameBoard.swift` | 2-D grid, tap-cycle helper, reset |
| `Models/GameState.swift` | Wraps board + timer + status for persistence |
| `Models/BestTime.swift` | Per-size personal best record |
| `Protocols/GameRepositoryProtocol.swift` | Save / load / clear in-progress game |
| `Protocols/BestTimesRepositoryProtocol.swift` | Save / query best times |
| `UseCases/GeneratePuzzleUseCase.swift` | Backtracking solver + flood-fill region colouring |
| `UseCases/ValidateMoveUseCase.swift` | Marks conflicting queens on the board |
| `UseCases/CheckWinUseCase.swift` | True when N queens placed with zero conflicts |

### Game rules encoded in domain
- One queen per **row** (enforced by backtracking row-by-row)
- One queen per **column** (tracked via `usedColumns` set)
- No two queens **adjacent** (including diagonals) – checked in placement + validation
- One queen per **coloured region** – enforced by flood-fill guarantee + `ValidateMoveUseCase`

### Puzzle generation algorithm
1. **Backtracking placement** – place one queen per row, picking columns in random order. Reject column if already used or adjacent to the previous row's queen. This runs in O(N!) worst case but is extremely fast for N≤15.
2. **Flood-fill colouring** – seed N regions at the queen positions, then iteratively expand each region to a random unassigned orthogonal neighbour. Result: exactly one queen per region.

---

## QueensData (Swift Package)

| File | Purpose |
|------|---------|
| `Repositories/GameRepository.swift` | UserDefaults + JSON; implements `GameRepositoryProtocol` |
| `Repositories/BestTimesRepository.swift` | UserDefaults + JSON; keeps only the personal best per size |

---

## QueensApp (Xcode target)

### App
- `QueensGameApp.swift` – `@main`, creates `AppDependencies`, injects into environment
- `AppDependencies.swift` – Composition root. Owns all use case and repository instances.

### Presentation / Home
- `HomeViewModel.swift` – Reads saved-game flag & best times on appear; creates new `GameState` via `GeneratePuzzleUseCase`; publishes `GameNavigationTarget` to trigger navigation
- `HomeView.swift` – Grid of size tiles (4–15), continue button, best times list

### Presentation / Game
- `GameViewModel.swift` – Owns the timer (`Task`), calls `ValidateMoveUseCase` on every queen placement, calls `CheckWinUseCase` after each queen added, persists via `GameRepository` on disappear
- `GameView.swift` – Top bar (timer + counter + reset), `BoardView`, win sheet
- `Components/BoardView.swift` – `Canvas` for background colours + region borders; `HStack/VStack` overlay for interactive `CellView`s
- `Components/CellView.swift` – Renders empty / X / queen states; spring animation on queen placement; switches to gold crown when it's the winning move
- `Components/QueensCounterView.swift` – Row of crown icons (filled = placed, outline = remaining)

### Presentation / Win
- `WinModal.swift` – Animated gold crown entrance, formatted time, personal-best badge
- `ConfettiView.swift` – Pure `Canvas` + `TimelineView` confetti with gravity simulation

---

## Tap cycle

```
empty  →  marked (✕)  →  queen (♛)  →  empty
```

After each queen placement `ValidateMoveUseCase` runs and marks conflicts in red.
After placing the Nth queen without conflicts, `CheckWinUseCase` triggers the win flow.

---

## How to integrate into your Xcode project

1. Drag `QueensDomain/` and `QueensData/` into your project root.
2. In **Project → Package Dependencies**, add both local packages.
3. In your app target's **Frameworks, Libraries, and Embedded Content**, add `QueensDomain` and `QueensData`.
4. Replace or add the files from `QueensApp/` to your app target (keeping your existing project file).
5. Ensure your deployment target is **iOS 17+** (required for `NavigationStack`, `Canvas`, and `TimelineView`).

---

## Running tests

```bash
# Domain tests (no Xcode required)
cd QueensDomain
swift test

# Data tests
cd QueensData
swift test
```
