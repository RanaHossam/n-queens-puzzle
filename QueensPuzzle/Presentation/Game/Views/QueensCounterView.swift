import SwiftUI
struct QueensCounterView: View {

    let total: Int
    let remaining: Int
    @State private var shakeTrigger: CGFloat = 0
    let shouldShakeCounter: Int

    @Environment(\.appTheme) private var theme

    private var placed: Int { total - remaining }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "crown.fill")
                .foregroundStyle(theme.colors.queenGoldTop)
            Text(L10n.queensProgress(placed: placed, total: total))
                .font(Typography.headlineMono)
                .frame(width: 54)
            progressView
        }
        .accessibilityLabel(L10n.queensRemaining)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .modifier(ShakeEffect(animatableData: shakeTrigger))
        .onChange(of: shouldShakeCounter) { _, newValue in
            if newValue > Int(shakeTrigger) {
                withAnimation(.default) {
                    shakeTrigger += 1
                }
            }
        }
    }
    
    private var progressView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.2))

                Capsule()
                    .fill(theme.colors.queenGoldTop)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(width: 60, height: 6)
    }

    private var progress: CGFloat {
        CGFloat(placed) / CGFloat(max(total, 1))
    }
}
