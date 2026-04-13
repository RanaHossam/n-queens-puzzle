//
//  L10n.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 10/04/2026.
//

import Foundation

enum L10n {

    // MARK: - Static strings

    static let appTitle         = String(localized: "queens_title")
    static let newGame          = String(localized: "new_game")
    static let continueGame     = String(localized: "continue_title")
    static let solvedTitle      = String(localized: "solved_title")
    static let doneButton       = String(localized: "done_title")
    static let reset            = String(localized: "reset_button")
    static let resetPuzzle      = String(localized: "reset_puzzle")
    static let helpInfo         = String(localized: "help_info")
    static let bestTimes        = String(localized: "best_times")
    static let newPersonalBest  = String(localized: "new_personal_best")
    static let queensRemaining  = String(localized: "queens_remaining")
    static let noBestTime       = String(localized: "no_best_time")
    static let crossMark        = String(localized: "cross_mark")
    static let settings         = String(localized: "settings_title")
    static let cancel           = String(localized: "cancel")
    static let abandonGame      = String(localized: "abandon_game_title")
    static let abandonGameMessage = String(localized: "abandon_game_message")
    static let changeLanguageTitle = String(localized: "change_language_title")
    static let appearanceTitle = String(localized: "appearance_title")
    static let languageTitle = String(localized: "language_title")
    static let classic   = String(localized: "classic_title")
    static let amethyst  = String(localized: "amethyst_title")
    static let ocean     = String(localized: "ocean_title")


    // MARK: - Format strings

    /// "\(n)×\(n)" — board size label, e.g. "8×8"
    static func boardSize(_ n: Int) -> String {
        String.localizedStringWithFormat(String(localized: "board_size_format"), n, n)
    }

    /// "\(n)×\(n) Queens" — navigation bar title
    static func navTitle(_ n: Int) -> String {
        String.localizedStringWithFormat(String(localized: "nav_title_format"), n, n)
    }

    /// "\(count) left" — remaining queens label for large boards
    static func queensLeft(_ count: Int) -> String {
        String.localizedStringWithFormat(String(localized: "queens_left_format"), count)
    }

    /// "\(placed)/\(total)" — progress fraction shown in the counter
    static func queensProgress(placed: Int, total: Int) -> String {
        String.localizedStringWithFormat(String(localized: "queens_progress_format"), placed, total)
    }

    /// "Best: \(time)" — best time label in win modal
    static func bestTimeLabel(_ time: String) -> String {
        String.localizedStringWithFormat(String(localized: "best_time_label"), time)
    }
}
