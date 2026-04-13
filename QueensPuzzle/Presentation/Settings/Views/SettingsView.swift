//
//  SettingsView.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 13/04/2026.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.dependenciesContainer) private var dependencies

    var body: some View {
        SettingsContentView(
            viewModel: SettingsViewModel()
        )
    }
}

struct SettingsContentView: View {

    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.appTheme) private var theme
    @Environment(\.openURL) private var openURL
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section {
                themePicker
            } header: {
                Text(L10n.appearanceTitle)
            }
            Section {
                languageRow
            } header: {
                Text(L10n.languageTitle)
            } footer: {
                Text(L10n.changeLanguageTitle)
                    .font(Typography.caption2)
            }
        }
        .navigationTitle(L10n.settings)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Theme Picker

    private var themePicker: some View {
        HStack(spacing: 0) {
            ForEach(ThemeIdentifier.allCases) { id in
                ThemeSwatch(
                    identifier: id,
                    isSelected: themeStore.selectedID == id
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        themeStore.selectedID = id
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Language Row

    private var languageRow: some View {
        Button {
            openAppSettings()
        } label: {
            HStack {
                Label("language_title", systemImage: "globe")
                    .foregroundStyle(.primary)
                Spacer()
                Text(currentLanguageDisplay)
                    .foregroundStyle(.secondary)
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }.foregroundStyle(Color.primary)
    }

    private var currentLanguageDisplay: String {
        let code = Bundle.main.preferredLocalizations.first ?? "en"
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code.uppercased()
    }

    private func openAppSettings() {
        if let url = URL(string: "app-settings:") {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(ThemeStore())
            .environment(\.appTheme, .default)
    }
}
