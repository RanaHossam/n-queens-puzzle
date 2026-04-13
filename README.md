# NxN Queens

A SwiftUI puzzle game where you place N queens on an N×N board so that no two queens share a row, column, or diagonal — the classical N-Queens problem, playable for board sizes 4 through 15.

---

## Requirements

| Tool | Minimum version |
|------|----------------|
| Xcode | 16.0 |
| iOS deployment target | 17.0 |
| Swift | 5.10 |

No external dependencies. All packages (`QueensDomain`, `QueensData`) are local Swift packages included in the repository.

---

## Build & Run

1. Open **`QueensPuzzle.xcodeproj`** in Xcode.
2. Select the **`QueensPuzzle`** scheme and an iOS simulator (or device).
3. Press **`⌘R`** to build and run.

---

## Testing

The project has three test targets, each run from a different scheme.

### 1 — Presentation layer (ViewModels)

These tests live in `QueensPuzzleTests/` and cover `HomeViewModel`, `GameViewModel`, and `SettingsViewModel`.

1. In the scheme picker, select **`QueensPuzzle`**.
2. Press **`⌘U`**.

### 2 — Data layer (Repositories)

These tests live in `QueensData/Tests/QueensDataTests/` and cover `BestTimesRepository`.

1. In the scheme picker, open the **`QueensData`** package (File → Open Recent, or navigate via the project navigator to the `QueensData` package).
   Alternatively, switch the active scheme to **`QueensDataTests`** while `QueensPuzzle.xcodeproj` is open.
2. Press **`⌘U`**.

### 3 — Domain layer (Use Cases)

These tests live in `QueensDomain/Tests/QueensDomainTests/` and cover all use cases: `GeneratePuzzleUseCase`, `ValidateMoveUseCase`, `CheckWinUseCase`, `LoadGameUseCase`, `UpdateGameStateUseCase`, `HasPendingGameUseCase`, and `BestTimeUseCase`.

1. Switch the active scheme to **`QueensDomainTests`**.
2. Press **`⌘U`**.

---

## Project structure

```
QueensPuzzle.xcodeproj   — main Xcode project
QueensPuzzle/            — app target (SwiftUI, MVVM)
QueensPuzzleTests/       — presentation-layer unit tests (Swift Testing)
QueensDomain/            — local Swift package: models, use cases, protocols
QueensData/              — local Swift package: UserDefaults-backed repositories
ARCHITECTURE.md          — full architecture reference
```

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for a detailed breakdown of every file, dependency graph, game rules, theme system, and localisation approach.
