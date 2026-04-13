# Theme Architecture — Queens Puzzle

## Overview

The app uses a lightweight injectable `AppTheme` struct passed through SwiftUI's environment. All views read colors from it via `@Environment(\.appTheme)` and never reference hardcoded color values directly. The active theme is owned by `ThemeStore`, an observable class that persists the user's selection to UserDefaults.

---

## Core Types

### `AppTheme`

A plain `Sendable` struct holding a `Colors` sub-struct.

```swift
struct AppTheme: Sendable {
    var colors: Colors
}
```

### `AppTheme.Colors`

All color values the UI needs:

```swift
struct Colors: Sendable {
    var cellLight: Color          // checkerboard light cell
    var cellDark: Color           // checkerboard dark cell
    var queenGoldTop: Color       // primary queen color (gradient top)
    var queenGoldBottom: Color    // primary queen color (gradient bottom)
    var queenConflict: Color      // conflict highlight
    var accent: Color             // buttons / accent UI

    // Computed gradients
    var queenGoldGradient: LinearGradient { ... }
    var queenGlowGradient: LinearGradient { ... }
}
```

### Environment Key

```swift
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}
extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
```

---

## Built-in Themes

Three themes ship with the app, each defined as a static `AppTheme` instance:

| Identifier | Display Name | Cells | Queen colors | Conflict |
|---|---|---|---|---|
| `.default` | Classic | Warm ivory / taupe (asset catalog) | Gold (asset catalog) | Red |
| `.ocean` | Ocean | Sky blue / slate | Cyan → deep blue | Orange |
| `.amethyst` | Amethyst | Lavender / muted violet | Bright violet → deep purple | Pink |

The **Classic** theme's colors live in the asset catalog (`Board/CellLight`, `Board/CellDark`, `Queen/GoldTop`, `Queen/GoldBottom`) so dark-mode variants can be added there without touching code. The Ocean and Amethyst themes use inline `Color(red:green:blue:)` values.

---

## Light / Dark Mode

Handled automatically for the Classic theme via the asset catalog — add a "Dark Appearance" variant to each color set in Xcode and the system picks it based on the device appearance. Ocean and Amethyst themes can be upgraded the same way if needed later.

---

## ThemeIdentifier

A `CaseIterable`, `Identifiable` enum that acts as the stable key for persistence and the picker UI:

```swift
enum ThemeIdentifier: String, CaseIterable, Identifiable {
    case `default`  = "default"
    case ocean      = "ocean"
    case amethyst   = "amethyst"

    var displayName: String { ... }   // "Classic", "Ocean", "Amethyst"
    var theme: AppTheme { ... }       // resolves to the AppTheme instance
    var swatchColors: (top: Color, bottom: Color) { ... }  // preview gradient in the picker
}
```

---

## ThemeStore

An `@Observable` class that owns the selection and syncs it to UserDefaults:

```swift
@Observable
final class ThemeStore {
    var selectedID: ThemeIdentifier {
        didSet { UserDefaults.standard.set(selectedID.rawValue, forKey: "selectedThemeID") }
    }

    var current: AppTheme { selectedID.theme }

    init() {
        let saved = UserDefaults.standard.string(forKey: "selectedThemeID") ?? ""
        selectedID = ThemeIdentifier(rawValue: saved) ?? .default
    }
}
```

---

## Root Injection

`ThemeStore` is created once at the app root as `@State` and passed two ways:

```swift
@main
struct QueensGameApp: App {
    @State private var themeStore = ThemeStore()

    var body: some Scene {
        WindowGroup {
            HomeView(...)
                .environment(\.appTheme, themeStore.current)  // theming for all views
                .environment(themeStore)                       // store access for the picker
        }
    }
}
```

When `themeStore.selectedID` changes, `themeStore.current` returns a new `AppTheme`, the root body re-evaluates, and `.environment(\.appTheme, ...)` propagates the new value to every view in the hierarchy instantly.

---

## Settings — Theme Picker

`SettingsView` reads both the store (to drive selection) and the current theme (for styling):

```swift
@Environment(ThemeStore.self) private var themeStore
@Environment(\.appTheme) private var theme
```

The picker renders one `ThemeSwatch` per `ThemeIdentifier.allCases`. Tapping a swatch sets `themeStore.selectedID`:

```swift
Button { themeStore.selectedID = id } label: { ... }
```

The selected swatch scales up (`scaleEffect(1.08)`), shows a white stroke ring and checkmark, and casts a colored shadow using the swatch's top color.

---

## Settings — Language

The language row shows the current app language (resolved from `Bundle.main.preferredLocalizations`) and opens iOS Settings via the `app-settings:` URL when tapped:

```swift
@Environment(\.openURL) private var openURL

if let url = URL(string: "app-settings:") {
    openURL(url)
}
```

In iOS Settings → Queens Puzzle → Language, the user can switch between English and Arabic (or any language added to the app's supported locales). SwiftUI handles RTL layout automatically when Arabic is active.

---

## Consuming Theme in Views

Every view that needs theme colors reads it the same way — no knowledge of `ThemeStore` required:

```swift
@Environment(\.appTheme) private var theme

.foregroundStyle(theme.colors.queenGoldTop)
.fill(theme.colors.queenGoldGradient)
.shadow(color: theme.colors.queenConflict, radius: 8)
```

---

## `@EnvironmentObject` vs `@Observable`

| | `@EnvironmentObject` (pre-iOS 17) | `@Observable` (iOS 17+) |
|---|---|---|
| Class annotation | `ObservableObject` | `@Observable` |
| Property tracking | `@Published` on each property | Automatic |
| Inject | `.environmentObject(store)` | `.environment(store)` |
| Consume | `@EnvironmentObject var store: T` | `@Environment(T.self) var store` |
| Re-render granularity | Whole view on any `@Published` change | Only properties actually read |

**For iOS 17+ projects, use `@Observable` + `.environment()` and skip `@EnvironmentObject`.**

---

## Adding a New Theme

1. Add a new case to `ThemeIdentifier` with a raw string value and `swatchColors`.
2. Add a static `AppTheme` instance with the desired colors.
3. Handle the new case in `ThemeIdentifier.theme` and `displayName`.
4. Optionally add color sets to the asset catalog for dark-mode support.

No changes needed in any view.
