import SwiftUI

struct InstructionsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme

    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    header
                    ForEach(AppInstructions.sections) { section in
                        card(section)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(AppInstructions.title(for: lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(theme.accent)
            }
            Text("WillWin")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(theme.textPrimary)
            Text(AppInstructions.tagline(for: lang))
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func card(_ section: InstructionSection) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: section.icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(theme.accent)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(section.title.s(lang))
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text(section.body.s(lang))
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
