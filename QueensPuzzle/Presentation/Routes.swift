//
//  Routes.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 10/04/2026.
//

import QueensDomain

enum NavigationRoute: Identifiable, Equatable, Hashable {
    case newGame(GameState)
    case resume(GameState)
    case settings

    var id: String {
        switch self {
        case .newGame: return "new"
        case .resume:  return "resume"
        case .settings: return "settings"
        }
    }

    var gameState: GameState? {
        switch self {
        case .newGame(let s), .resume(let s): return s
        default:
            return nil
        }
    }
    
    static func == (lhs: NavigationRoute, rhs: NavigationRoute) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum SheetRoute: Identifiable {
    case celebration
    
    var id: String {
        switch self {
        case .celebration:
            return "celebration"
        }
    }
}
