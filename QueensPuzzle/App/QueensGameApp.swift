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

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: dependencies.homeViewModel)
                .environmentObject(dependencies.router)
                .environment(\.dependenciesContainer, dependencies)
                .environment(\.appTheme, themeStore.current)
                .environment(themeStore)
        }
    }
}

extension EnvironmentValues {
    @Entry var dependenciesContainer: AppDependencies = .mock
}
