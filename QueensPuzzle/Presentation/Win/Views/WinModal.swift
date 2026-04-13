import SwiftUI
import QueensDomain

struct WinModal: View {

    @ObservedObject var viewModel: WinModalViewModel
    let onDismiss: () -> Void

    @State private var crownScale: CGFloat = 0.1
    @State private var crownOpacity: Double = 0

    @Environment(\.appTheme) private var theme

    var body: some View {
        ZStack {
            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(theme.colors.queenGoldGradient)
                    .shadow(color: theme.colors.queenGoldTop.opacity(0.6), radius: Radius.xl)
                    .scaleEffect(crownScale)
                    .opacity(crownOpacity)

                Text(L10n.solvedTitle)
                    .font(Typography.largeTitle)

                VStack(spacing: Spacing.sm) {
                    Label(viewModel.formattedTime, systemImage: "stopwatch")
                        .font(.title2.monospacedDigit())
                        .foregroundStyle(.primary)

                    if viewModel.isPersonalBest {
                        Label(L10n.newPersonalBest, systemImage: "star.fill")
                            .font(Typography.subheadlineBold)
                            .foregroundStyle(theme.colors.queenGoldTop)
                    } else if let prev = viewModel.previousBest {
                        Text(L10n.bestTimeLabel(prev.formattedTime))
                            .font(Typography.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    onDismiss()
                } label: {
                    Text(L10n.doneButton)
                        .font(Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.lg)
                        .background(theme.colors.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(Spacing.xxl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                crownScale = 1.0
                crownOpacity = 1.0
            }
        }
    }
}
