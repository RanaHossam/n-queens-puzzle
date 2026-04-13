//
//  GameView.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 12/04/2026.
//

import SwiftUI
import QueensDomain
import QueensData

struct GameView: View {
    
    @Environment(\.dependenciesContainer) private var dependencies
    private let initialState: GameState

    init(initialState: GameState) {
        self.initialState = initialState
    }

    var body: some View {
        GameContentView(initialState: initialState, dependencies: dependencies)
    }
}

struct GameContentView: View {
    @EnvironmentObject var router: Router
    @StateObject private var vm: GameViewModel
    @Environment(\.appTheme) private var theme

    init(initialState: GameState, dependencies: AppDependencies) {
        _vm = StateObject(wrappedValue: GameViewModel(
            initialState: initialState,
            validateMove: dependencies.validateMove,
            checkWin: dependencies.checkWin,
            updateStateUseCase: dependencies.updateStateUseCase,
            bestTimesUseCase: dependencies.bestTimesUseCase
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            BoardView(
                board: vm.board,
                isWon: vm.didWin
            ) { position in
                Task {
                    await vm.tap(at: position)
                }
            }
            .padding(Spacing.lg)
            Spacer()
        }
        .navigationTitle(L10n.navTitle(vm.board.size))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .sheet(isPresented: $vm.showWinModal) {
            WinModal(
                viewModel: WinModalViewModel(
                    boardSize: vm.board.size,
                    elapsedSeconds: vm.elapsedSeconds,
                    previousBestTime: vm.previousBestTime
                ),
                onDismiss: {
                    // TODO: - could be extracted to a coordinator layer
                    router.pop()
                }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Label(vm.formattedTime, systemImage: "stopwatch")
                .font(Typography.headlineMono)

            Spacer()

            if vm.board.size <= 10 {
                QueensCounterView(total: vm.board.size, remaining: vm.queensRemaining, shouldShakeCounter: vm.shouldShakeCounter)
                    .foregroundStyle(vm.conflictingQueensCount > 0 ? theme.colors.queenConflict : theme.colors.queenGoldTop)
            } else {
                Label(L10n.queensLeft(vm.queensRemaining), systemImage: "crown")
                    .font(Typography.headline)
                    .foregroundStyle(vm.conflictingQueensCount > 0 ? theme.colors.queenConflict : theme.colors.queenGoldTop)
            }

            Spacer()

            Button {
                vm.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.resetPuzzle)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.md)
    }
}

#Preview {
    GameView(initialState: GameState.init(board: .mockEmpty(size: 4)))
        .environment(\.dependenciesContainer, AppDependencies())
}
