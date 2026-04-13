//
//  HomeView.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 12/04/2026.
//

import SwiftUI
import QueensDomain
import Combine

// Wrapper to pass view model initializers explicitly to the content view, as in the init the env vars are not yet loaded

struct HomeView: View {
    
    @Environment(\.dependenciesContainer) private var dependencies
    @EnvironmentObject var router: Router

    var body: some View {
        HomeContentView(
            dependencies: dependencies,
            router: router
        )
    }
}

public struct HomeContentView: View {
    
    @StateObject var viewModel: HomeViewModel
    @Environment(\.appTheme) private var theme
    @EnvironmentObject var router: Router
    
    init(dependencies: AppDependencies, router: Router) {
        let viewModel = HomeViewModel(
            loadGameUseCase: dependencies.loadGameUseCase,
            hasPendingGameUseCase: dependencies.hasPendingGameUseCase,
            bestTimeUseCase: dependencies.bestTimesUseCase,
            updateStateUseCase: dependencies.updateStateUseCase,
            generatePuzzle: dependencies.generatePuzzle,
            router: router
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                content(vm: viewModel)
            }
            .alert(L10n.abandonGame,
                   isPresented: $viewModel.showingConfirmation,
                   actions: {
                Button(L10n.newGame, role: .confirm) {
                    viewModel.confirmNewGame()
                }
                Button(L10n.cancel, role: .cancel) { }
            }, message: {
                Text(L10n.abandonGameMessage)
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        router.push(route: .settings)
                    }, label: {
                        Image(systemName: "gearshape")
                    })
                }
            })
            .navigationDestination(for: NavigationRoute.self) { destination in
                switch destination {
                case .newGame(let state), .resume(let state):
                    GameView(initialState: state)
                case .settings:
                    SettingsView()
                }
            }
            .navigationTitle(L10n.appTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }

    // MARK: - Content
    @ViewBuilder
    private func content(vm: HomeViewModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.xxl) {
                header

                if vm.hasSavedGame {
                    continueButton(vm: vm)
                }

                sizeGrid(vm: vm)

                if !vm.bestTimes.isEmpty {
                    bestTimesSection(vm: vm)
                }
            }
            .padding(Spacing.lg)
        }
    }

    // MARK: - Sub-views

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.colors.queenGoldTop)
            Text(L10n.helpInfo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Spacing.lg)
    }

    private func continueButton(vm: HomeViewModel) -> some View {
        Button {
            vm.continueGame()
        } label: {
            Label(L10n.continueGame, systemImage: "arrow.counterclockwise")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(Spacing.lg)
                .background(theme.colors.ctaBackground)
                .foregroundStyle(theme.colors.ctaText)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
    }

    private func sizeGrid(vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(L10n.newGame)
                .font(Typography.title3Bold)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: Spacing.md) {
                ForEach(vm.getPuzzleMin()...vm.getPuzzleMax(), id: \.self) { size in
                    SizeTile(
                        size: size,
                        bestTime: vm.bestTime(for: size)
                    ) {
                        vm.startNewGame(size: size)
                    }
                }
            }.id(vm.bestTimes)
        }
    }

    private func bestTimesSection(vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(L10n.bestTimes)
                .font(Typography.title3Bold)

            ForEach(vm.bestTimes.sorted { $0.boardSize < $1.boardSize }) { record in
                HStack {
                    Text(L10n.boardSize(record.boardSize))
                        .font(Typography.headline)
                    Spacer()
                    Label(record.formattedTime, systemImage: "stopwatch")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(Spacing.md)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(theme.colors.accent.opacity(0.3), lineWidth: LineWidth.sm)
                )
            }
        }
    }
}
