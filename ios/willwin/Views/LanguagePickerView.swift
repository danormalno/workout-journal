import SwiftUI

struct LanguagePickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    
    private let options: [(AppLanguage, String, String)] = [
        (.uk, "Українська", "🇺🇦"),
        (.en, "English", "🇬🇧"),
        (.ru, "Русский", "🇷🇺"),
        (.es, "Español", "🇪🇸"),
        (.de, "Deutsch", "🇩🇪"),
        (.fr, "Français", "🇫🇷"),
        (.pt, "Português", "🇵🇹"),
        (.pl, "Polski", "🇵🇱"),
        (.it, "Italiano", "🇮🇹"),
    ]
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("WillWin")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.accent)
                    Text("💪")
                        .font(.system(size: 40))
                }
                .padding(.top, 40)
                
                VStack(spacing: 4) {
                    Text("Оберіть мову / Choose your language")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(theme.textPrimary)
                }
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(options, id: \.0) { item in
                            languageButton(title: item.1, flag: item.2, lang: item.0)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private func languageButton(title: String, flag: String, lang: AppLanguage) -> some View {
        Button {
            withAnimation { appState.setLanguage(lang) }
        } label: {
            HStack {
                Text(flag).font(.title)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(theme.textSecondary)
            }
            .padding()
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
