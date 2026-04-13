//
//  AppTheme.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 10/04/2026.
//

import SwiftUI

// MARK: - AppTheme

/// Lightweight injectable theme. Swap the environment value to change the
/// entire visual style of the app without touching individual views.
struct AppTheme: Sendable {
    var colors: Colors
}

// MARK: - Colors

extension AppTheme {

    struct Colors: Sendable {

        // MARK: Board (checkerboard cells)
        var cellLight: Color
        var cellDark: Color

        // MARK: Queen states
        var queenGoldTop: Color
        var queenGoldBottom: Color
        var queenConflict: Color

        // MARK: UI
        var accent: Color
        var ctaBackground: Color
        var ctaText: Color

        // MARK: Computed helpers (kept here so callers don't repeat gradient setup)

        var queenGoldGradient: LinearGradient {
            LinearGradient(
                colors: [queenGoldTop, queenGoldBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        var queenGlowGradient: LinearGradient {
            LinearGradient(
                colors: [queenGoldTop.opacity(0.8), queenGoldBottom.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Built-in themes

extension AppTheme {

    static let `default` = AppTheme(
        colors: Colors(
            cellLight: Color("Board/CellLight"),
            cellDark: Color("Board/CellDark"),
            queenGoldTop: Color("Queen/GoldTop"),
            queenGoldBottom: Color("Queen/GoldBottom"),
            queenConflict: .red,
            accent: Color("Queen/GoldTop"),
            ctaBackground: Color("Queen/GoldTop"),
            ctaText: .black
        )
    )

    static let ocean = AppTheme(
        colors: Colors(
            cellLight: Color(red: 0.898, green: 0.937, blue: 0.961),
            cellDark: Color(red: 0.580, green: 0.690, blue: 0.769),
            queenGoldTop: Color(red: 0.161, green: 0.714, blue: 0.965),
            queenGoldBottom: Color(red: 0.012, green: 0.416, blue: 0.675),
            queenConflict: .red,
            accent: .blue,
            ctaBackground: Color(red: 0.161, green: 0.714, blue: 0.965),
            ctaText: .white
        )
    )

    static let amethyst = AppTheme(
        colors: Colors(
            cellLight: Color(red: 0.949, green: 0.933, blue: 0.969),
            cellDark: Color(red: 0.643, green: 0.549, blue: 0.753),
            queenGoldTop: Color(red: 0.741, green: 0.392, blue: 0.863),
            queenGoldBottom: Color(red: 0.392, green: 0.086, blue: 0.612),
            queenConflict: .pink,
            accent: .purple,
            ctaBackground: Color(red: 0.741, green: 0.392, blue: 0.863),
            ctaText: .white
        )
    )
}

// MARK: - Theme Catalogue

/// Stable identifier for a built-in theme. Persisted to UserDefaults as its raw string value.
enum ThemeIdentifier: String, CaseIterable, Identifiable {
    case `default`  = "default"
    case ocean      = "ocean"
    case amethyst   = "amethyst"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default:  return L10n.classic
        case .ocean:    return L10n.ocean
        case .amethyst: return L10n.amethyst
        }
    }

    var theme: AppTheme {
        switch self {
        case .default:  return .default
        case .ocean:    return .ocean
        case .amethyst: return .amethyst
        }
    }

    /// Top and bottom swatch preview colors for the picker UI.
    var swatchColors: (top: Color, bottom: Color) {
        switch self {
        case .default:  return (Color("Queen/GoldTop"), Color("Queen/GoldBottom"))
        case .ocean:    return (Color(red: 0.161, green: 0.714, blue: 0.965),
                                Color(red: 0.012, green: 0.416, blue: 0.675))
        case .amethyst: return (Color(red: 0.741, green: 0.392, blue: 0.863),
                                Color(red: 0.392, green: 0.086, blue: 0.612))
        }
    }
}

// MARK: - ThemeStore

/// Observable store that owns the active theme selection and persists it to UserDefaults.
/// Inject at the app root via `.environment(themeStore)` and read with `@Environment(ThemeStore.self)`.
@Observable
final class ThemeStore {
    private static let userDefaultsKey = "selectedThemeID"

    var selectedID: ThemeIdentifier {
        didSet {
            UserDefaults.standard.set(selectedID.rawValue, forKey: Self.userDefaultsKey)
        }
    }

    /// The resolved `AppTheme` for the current selection. Use this as the env value.
    var current: AppTheme { selectedID.theme }

    init() {
        let saved = UserDefaults.standard.string(forKey: Self.userDefaultsKey) ?? ""
        selectedID = ThemeIdentifier(rawValue: saved) ?? .default
    }
}

// MARK: - Environment

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - Spacing

enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 14
    static let xl: CGFloat = 16
    
}

enum LineWidth {
    static let xs:  CGFloat = 0.5
    static let sm: CGFloat = 1
    static let md: CGFloat = 2
    static let lg: CGFloat = 3
}

// MARK: - Typography
// Static namespace — fonts don't vary per theme in this app.
// Promote to an AppTheme property if you ever need per-theme type scales.

enum Typography {
    static let largeTitle      = Font.largeTitle.bold()
    static let title2          = Font.title2
    static let title3Bold      = Font.title3.bold()
    static let headline        = Font.headline
    static let headlineMono    = Font.headline.monospacedDigit()
    static let subheadline     = Font.subheadline
    static let subheadlineBold = Font.subheadline.bold()
    static let caption2        = Font.caption2
}
