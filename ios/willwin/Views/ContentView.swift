import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var systemColorScheme
    @ObservedObject private var timerService = RestTimerService.shared

    /// Обраний акцентний колір. Порожньо = стандартний колір теми.
    @AppStorage("willwin_accent") private var accentRaw: String = ""
    /// Обрана заставка.
    @AppStorage(WallpaperStore.choiceKey) private var wallpaperChoiceRaw = WallpaperChoice.none.rawValue
    @AppStorage("willwin_selected_tab") private var selectedTab = 0

    init() {
        // Робимо системні бари напівпрозорими/прозорими, щоб заставка
        // проглядалась за вмістом, а не перекривалась суцільним фоном.
        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()   // матовий, напівпрозорий бар
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        let nav = UINavigationBarAppearance()
        nav.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }
    
    var body: some View {
        Group {
            if appState.data.settings.language == nil {
                LanguagePickerView()
            } else {
                ZStack(alignment: .top) {
                    mainTabView
                    if timerService.isRunning {
                        timerBanner
                            .padding(.top, 4)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: timerService.isRunning)
            }
        }
        .environment(\.strings, Strings.current(for: appState.data.settings.language))
        .environment(\.appTheme, currentTheme())
        .preferredColorScheme(swiftUIColorScheme())
        .scrollDismissesKeyboard(.interactively)
        .onAppear { KeyboardToolbar.install(doneTitle: Strings.current(for: appState.data.settings.language).done) }
        .onChange(of: appState.data.settings.language) { _, language in
            KeyboardToolbar.install(doneTitle: Strings.current(for: language).done)
        }
        .safeAreaInset(edge: .bottom) {
            if appState.saveFailed {
                Text(saveFailureMessage)
                    .font(.footnote)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundStyle(.white)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                appState.saveNow()
            }
        }
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            WeeksListView()
                .background(WallpaperBackground())
                .tabItem {
                    Label(Strings.current(for: appState.data.settings.language).weeks,
                          systemImage: "calendar")
                }
                .tag(0)
            ProgressTabView()
                .background(WallpaperBackground())
                .tabItem {
                    Label(Strings.current(for: appState.data.settings.language).progress,
                          systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            BodyWeightTabView()
                .background(WallpaperBackground())
                .tabItem {
                    Label(Strings.current(for: appState.data.settings.language).bodyWeight,
                          systemImage: "scalemass")
                }
                .tag(2)
            SettingsTabView()
                .background(WallpaperBackground())
                .tabItem {
                    Label(Strings.current(for: appState.data.settings.language).settings,
                          systemImage: "gearshape")
                }
                .tag(3)
        }
    }
    
    private var saveFailureMessage: String {
        switch appState.data.settings.language {
        case .en: return "Changes could not be saved. Check free storage. Retrying…"
        case .ru: return "Не удалось сохранить изменения. Проверьте свободное место. Повторяем…"
        case .es: return "No se pudieron guardar los cambios. Comprueba el espacio libre. Reintentando…"
        case .de: return "Änderungen nicht gespeichert. Freien Speicher prüfen. Neuer Versuch…"
        case .fr: return "Échec de l’enregistrement. Vérifiez l’espace libre. Nouvelle tentative…"
        case .pt: return "Não foi possível salvar. Verifique o espaço livre. Tentando novamente…"
        case .pl: return "Nie zapisano zmian. Sprawdź wolne miejsce. Ponawiam…"
        case .it: return "Modifiche non salvate. Controlla lo spazio libero. Nuovo tentativo…"
        default: return "Не вдалося зберегти зміни. Перевірте вільне місце. Повторюємо запис…"
        }
    }

    private var timerBanner: some View {
        let theme = currentTheme()
        let s = Strings.current(for: appState.data.settings.language)
        
        return Group {
            if timerService.isAlerting {
                alertingBanner(theme: theme, s: s)
            } else {
                countdownBanner(theme: theme, s: s)
            }
        }
        .padding(.horizontal, 16)
    }
    
    /// Звичайний відлік — показує час що залишився
    private func countdownBanner(theme: AppTheme, s: Strings) -> some View {
        let m = timerService.remainingSeconds / 60
        let sec = timerService.remainingSeconds % 60
        let display = m > 0 ? String(format: "%d:%02d", m, sec) : "\(sec) \(s.sec)"
        
        return HStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.title3)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 0) {
                Text(s.restAfterSet)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
                Text(display)
                    .font(.headline).fontWeight(.bold)
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            Spacer()
            Button {
                timerService.cancelAndClear()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.accent)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
    
    /// Режим сигналізації — таймер вже закінчився, чекаємо натискання Go!
    private func alertingBanner(theme: AppTheme, s: Strings) -> some View {
        Button {
            timerService.confirmAlert()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                Text("Go!")
                    .font(.title2).fontWeight(.heavy)
                    .foregroundStyle(.white)
                Spacer()
                Text(alertReadyText())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.green)
                    .shadow(color: .green.opacity(0.5), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(timerService.isAlerting ? 1.0 : 0.95)
        .animation(
            .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
            value: timerService.isAlerting
        )
    }
    
    private func alertReadyText() -> String {
        switch appState.data.settings.language {
        case .en: return "Tap to continue"
        case .ru: return "Нажми, чтобы продолжить"
        case .es: return "Toca para continuar"
        case .de: return "Tippen zum Fortfahren"
        case .fr: return "Appuie pour continuer"
        case .pt: return "Toque para continuar"
        case .pl: return "Stuknij aby kontynuować"
        case .it: return "Tocca per continuare"
        default: return "Тапни щоб продовжити"
        }
    }
    
    private func currentTheme() -> AppTheme {
        var base: AppTheme
        switch appState.data.settings.colorScheme {
        case .light: base = .defaultLight
        case .dark:  base = .defaultDark
        case .system:
            base = systemColorScheme == .dark ? .defaultDark : .defaultLight
        }
        // Підміна акценту, якщо обраний
        if let palette = AccentPalette(rawValue: accentRaw) {
            base.accent = palette.color
        }
        // Якщо активна заставка — робимо фон екранів прозорим,
        // щоб вона проглядалась (картки лишаються непрозорими для читабельності).
        if (WallpaperChoice(rawValue: wallpaperChoiceRaw) ?? .none) != .none {
            base.background = .clear
        }
        return base
    }
    
    private func swiftUIColorScheme() -> SwiftUI.ColorScheme? {
        switch appState.data.settings.colorScheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
