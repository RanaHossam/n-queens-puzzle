//
//  QueensGameApp.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 09/04/2026.
//

import SwiftUI

@main
struct QueensGameApp: App {

    private let dependencies = AppDependencies()
    @State private var themeStore = ThemeStore()
    @State private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(router)
                .environment(\.dependenciesContainer, dependencies)
                .environment(\.appTheme, themeStore.current)
                .environment(themeStore)
        }
    }
}

extension EnvironmentValues {
    @Entry var dependenciesContainer: AppDependencies = .default
}
