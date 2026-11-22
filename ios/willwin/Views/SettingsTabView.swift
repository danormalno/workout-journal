import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.strings) var s
    @Environment(\.appTheme) var theme
    
    @State private var showingImporter: Bool = false
    @State private var importMessage: String? = nil
    @State private var showingImportAlert: Bool = false
    @State private var shareItem: ShareItem? = nil

    /// Обраний акцентний колір. Порожньо = стандартний колір теми.
    @AppStorage("willwin_accent") private var accentRaw: String = ""

    // Заставка
    @AppStorage(WallpaperStore.choiceKey) private var wpChoiceRaw = WallpaperChoice.none.rawValue
    @AppStorage(WallpaperStore.scrimKey)  private var wpScrimRaw  = WallpaperScrim.none.rawValue
    @AppStorage(WallpaperStore.amountKey) private var wpAmount    = 0.25
    @State private var wpPhotoItem: PhotosPickerItem? = nil

    private var lang: AppLanguage? { appState.data.settings.language }

    private var restOptions: [Int] {
        var set = Set([30, 45, 60, 75, 90, 105, 120, 150, 180, 210, 240, 300])
        set.insert(max(1, appState.data.settings.defaultRestSeconds))
        return set.sorted()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                WallpaperBackground()
                Form {
                    // Тема
                    Section(themeSectionTitle) {
                        Picker("", selection: Binding(
                            get: { appState.data.settings.colorScheme },
                            set: { appState.setColorScheme($0) }
                        )) {
                            Text(themeLightLabel).tag(ColorScheme.light)
                            Text(themeDarkLabel).tag(ColorScheme.dark)
                            Text(themeSystemLabel).tag(ColorScheme.system)
                        }
                        .pickerStyle(.segmented)

                        // Акцентний колір
                        accentPicker
                    }
                    
                    // Заставка
                    Section {
                        wallpaperControls
                    } header: {
                        Text(wpTitle)
                    } footer: {
                        Text(wpWarning).font(.caption2)
                    }
                    
                    // Таймер
                    Section(s.restTimer) {
                        Picker(s.timerSound, selection: Binding(
                            get: { appState.data.settings.timerSound },
                            set: { appState.setTimerSound($0) }
                        )) {
                            ForEach(TimerSound.allCases, id: \.self) { sound in
                                Text(s.soundName(sound)).tag(sound)
                            }
                        }
                        
                        Button {
                            RestTimerService.shared.preview(sound: appState.data.settings.timerSound)
                            if appState.data.settings.hapticsEnabled {
                                let g = UINotificationFeedbackGenerator()
                                g.notificationOccurred(.success)
                            }
                        } label: {
                            Label(s.preview, systemImage: "speaker.wave.2")
                        }
                        
                        Toggle(s.vibration, isOn: Binding(
                            get: { appState.data.settings.hapticsEnabled },
                            set: { appState.setHapticsEnabled($0) }
                        ))
                        
                        Picker(alertModeTitle, selection: Binding(
                            get: { appState.data.settings.timerAlertMode },
                            set: { appState.setTimerAlertMode($0) }
                        )) {
                            Text(alertModeSoundAndVibration).tag(TimerAlertMode.soundAndVibration)
                            Text(alertModeVibrationOnly).tag(TimerAlertMode.vibrationOnly)
                        }
                        
                        Picker(s.defaultRestTime, selection: Binding(
                            get: { appState.data.settings.defaultRestSeconds },
                            set: { appState.setDefaultRestSeconds($0) }
                        )) {
                            ForEach(restOptions, id: \.self) { v in
                                Text("\(v) \(s.sec)").tag(v)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Цикл
                    Section(s.cycleSize) {
                        Stepper(value: Binding(
                            get: { appState.data.settings.defaultCycleSize },
                            set: { appState.setDefaultCycleSize(max(1, min(14, $0))) }
                        ), in: 1...14) {
                            HStack {
                                Text(s.cycleSizeGlobal)
                                Spacer()
                                Text("\(appState.data.settings.defaultCycleSize)")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }
                    
                    // Діапазон графіка
                    Section(chartRangeTitle) {
                        Picker("", selection: Binding(
                            get: { appState.data.settings.progressChartRange },
                            set: { appState.setProgressChartRange($0) }
                        )) {
                            ForEach(ProgressChartRange.allCases, id: \.self) { range in
                                Text(chartRangeLabel(range)).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Мова
                    Section("Language / Мова") {
                        Picker("", selection: Binding(
                            get: { appState.data.settings.language ?? .uk },
                            set: { appState.setLanguage($0) }
                        )) {
                            Text("🇺🇦 Українська").tag(AppLanguage.uk)
                            Text("🇬🇧 English").tag(AppLanguage.en)
                            Text("🇷🇺 Русский").tag(AppLanguage.ru)
                            Text("🇪🇸 Español").tag(AppLanguage.es)
                            Text("🇩🇪 Deutsch").tag(AppLanguage.de)
                            Text("🇫🇷 Français").tag(AppLanguage.fr)
                            Text("🇵🇹 Português").tag(AppLanguage.pt)
                            Text("🇵🇱 Polski").tag(AppLanguage.pl)
                            Text("🇮🇹 Italiano").tag(AppLanguage.it)
                        }
                        .pickerStyle(.inline)
                        .labelsHidden()
                    }
                    
                    // Дані
                    Section(dataSectionTitle) {
                        Button {
                            exportData()
                        } label: {
                            Label(exportLabel, systemImage: "square.and.arrow.up")
                        }
                        Button {
                            showingImporter = true
                        } label: {
                            Label(importLabel, systemImage: "square.and.arrow.down")
                        }
                        // CSV-експорт
                        Button {
                            exportCSV()
                        } label: {
                            Label(csvLabel, systemImage: "tablecells")
                        }
                    }
                    
                    Section {
                        NavigationLink {
                            InstructionsView()
                        } label: {
                            Label(AppInstructions.title(for: appState.data.settings.language), systemImage: "book.fill")
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("WillWin").fontWeight(.semibold)
                            Spacer()
                            Text("v" + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2.0.2"))
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(theme.background)
            }
            .navigationTitle(s.settings)
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert(importMessage ?? "", isPresented: $showingImportAlert) {
                Button(s.done, role: .cancel) { }
            }
            .sheet(item: $shareItem) { item in
                ShareSheet(items: [item.url])
            }
        }
    }
    
    // MARK: - Локалізовані тексти секцій

    private var wallpaperControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker(wpTitle, selection: $wpChoiceRaw) {
                ForEach([WallpaperChoice.none, .dark, .light, .pink], id: \.self) { c in
                    Text(c.title.s(lang)).tag(c.rawValue)
                }
            }
            .pickerStyle(.segmented)

            PhotosPicker(selection: $wpPhotoItem, matching: .images) {
                Label(WallpaperChoice.custom.title.s(lang), systemImage: "photo.on.rectangle")
                    .foregroundStyle(theme.accent)
            }
            if wpChoiceRaw == WallpaperChoice.custom.rawValue {
                Text(wpCustomActive).font(.caption2).foregroundStyle(theme.textSecondary)
            }

            Divider()

            Text(wpScrimTitle).font(.caption).foregroundStyle(theme.textSecondary)
            Picker(wpScrimTitle, selection: $wpScrimRaw) {
                ForEach(WallpaperScrim.allCases) { sc in
                    Text(sc.title.s(lang)).tag(sc.rawValue)
                }
            }
            .pickerStyle(.segmented)
            if wpScrimRaw != WallpaperScrim.none.rawValue {
                Slider(value: $wpAmount, in: 0.05...0.6)
            }
        }
        .onChange(of: wpPhotoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    WallpaperStore.saveCustom(data)
                    wpChoiceRaw = WallpaperChoice.custom.rawValue
                }
            }
        }
    }

    private var wpTitle: String {
        LocStr("Заставка","Wallpaper","Обои","Fondo","Hintergrund","Fond d'écran","Papel de parede","Tapeta","Sfondo").s(lang)
    }
    private var wpScrimTitle: String {
        LocStr("Читабельність тексту","Text readability","Читаемость текста","Legibilidad del texto","Lesbarkeit","Lisibilité du texte","Legibilidade","Czytelność tekstu","Leggibilità").s(lang)
    }
    private var wpCustomActive: String {
        LocStr("Своє фото обрано ✓","Your photo selected ✓","Своё фото выбрано ✓","Tu foto seleccionada ✓","Eigenes Foto gewählt ✓","Votre photo choisie ✓","Sua foto selecionada ✓","Twoje zdjęcie wybrane ✓","Tua foto selezionata ✓").s(lang)
    }
    private var wpWarning: String {
        LocStr(
            "Текст може зливатися з фоном, якщо заставку підібрано невдало. За потреби затемни або освітли її нижче. Порада: темна — до темної теми, світла — до світлої, рожева — до світлої жіночої.",
            "Text may blend with the background if the wallpaper is poorly chosen. Darken or lighten it below if needed. Tip: dark suits the dark theme, light the light one, pink a light feminine look.",
            "Текст может сливаться с фоном, если обои подобраны неудачно. При необходимости затемни или осветли ниже. Совет: тёмная — для тёмной темы, светлая — для светлой, розовая — для светлой женской.",
            "El texto puede mezclarse con el fondo si eliges mal. Oscurécelo o aclátalo abajo. Consejo: oscuro para tema oscuro, claro para claro, rosa para un look femenino claro.",
            "Der Text kann mit dem Hintergrund verschmelzen. Bei Bedarf unten abdunkeln oder aufhellen. Tipp: dunkel zum dunklen Theme, hell zum hellen, rosa für hellen femininen Look.",
            "Le texte peut se fondre dans le fond. Assombris ou éclaircis ci-dessous si besoin. Astuce : sombre pour le thème sombre, clair pour le clair, rose pour un look féminin clair.",
            "O texto pode se misturar ao fundo. Escureça ou clareie abaixo se precisar. Dica: escuro para o tema escuro, claro para o claro, rosa para um visual feminino claro.",
            "Tekst może zlewać się z tłem. W razie potrzeby przyciemnij lub rozjaśnij poniżej. Wskazówka: ciemna do ciemnego motywu, jasna do jasnego, różowa do jasnego kobiecego.",
            "Il testo può confondersi con lo sfondo. Se serve, scuriscilo o schiariscilo sotto. Consiglio: scuro per il tema scuro, chiaro per quello chiaro, rosa per un look femminile chiaro."
        ).s(lang)
    }

    private var accentPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(accentLabel)
                .font(.subheadline)
                .foregroundStyle(theme.textPrimary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 46), spacing: 12)], spacing: 12) {
                ForEach(AccentPalette.allCases) { p in
                    let selected = accentRaw == p.rawValue
                    Button {
                        accentRaw = p.rawValue
                    } label: {
                        ZStack {
                            Circle().fill(p.color).frame(width: 36, height: 36)
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(3)
                        .overlay(Circle().stroke(theme.textPrimary.opacity(selected ? 0.45 : 0), lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var accentLabel: String {
        switch appState.data.settings.language {
        case .en: return "Accent color"
        case .ru: return "Цвет акцента"
        case .es: return "Color de acento"
        case .de: return "Akzentfarbe"
        case .fr: return "Couleur d'accent"
        case .pt: return "Cor de destaque"
        case .pl: return "Kolor akcentu"
        case .it: return "Colore d'accento"
        default: return "Акцентний колір"
        }
    }
    
    private var alertModeTitle: String {
        switch appState.data.settings.language {
        case .en: return "Alert mode"
        case .ru: return "Режим сигнала"
        case .es: return "Modo de alerta"
        case .de: return "Alarm-Modus"
        case .fr: return "Mode d'alerte"
        case .pt: return "Modo de alerta"
        case .pl: return "Tryb alarmu"
        case .it: return "Modalità avviso"
        default: return "Режим сигналу"
        }
    }
    
    private var alertModeSoundAndVibration: String {
        switch appState.data.settings.language {
        case .en: return "Sound + Vibration"
        case .ru: return "Звук + Вибрация"
        case .es: return "Sonido + Vibración"
        case .de: return "Ton + Vibration"
        case .fr: return "Son + Vibration"
        case .pt: return "Som + Vibração"
        case .pl: return "Dźwięk + Wibracja"
        case .it: return "Suono + Vibrazione"
        default: return "Звук + Вібрація"
        }
    }
    
    private var alertModeVibrationOnly: String {
        switch appState.data.settings.language {
        case .en: return "Vibration only"
        case .ru: return "Только вибрация"
        case .es: return "Solo vibración"
        case .de: return "Nur Vibration"
        case .fr: return "Vibration seulement"
        case .pt: return "Apenas vibração"
        case .pl: return "Tylko wibracja"
        case .it: return "Solo vibrazione"
        default: return "Тільки вібрація"
        }
    }
    
    private var themeSectionTitle: String {
        switch appState.data.settings.language {
        case .en: return "Theme"
        case .ru: return "Тема"
        case .es: return "Tema"
        case .de: return "Design"
        case .fr: return "Thème"
        case .pt: return "Tema"
        case .pl: return "Motyw"
        case .it: return "Tema"
        default: return "Тема"
        }
    }
    
    private var themeLightLabel: String {
        switch appState.data.settings.language {
        case .en: return "Light"
        case .ru: return "Светлая"
        case .es: return "Claro"
        case .de: return "Hell"
        case .fr: return "Clair"
        case .pt: return "Claro"
        case .pl: return "Jasny"
        case .it: return "Chiaro"
        default: return "Світла"
        }
    }
    
    private var themeDarkLabel: String {
        switch appState.data.settings.language {
        case .en: return "Dark"
        case .ru: return "Тёмная"
        case .es: return "Oscuro"
        case .de: return "Dunkel"
        case .fr: return "Sombre"
        case .pt: return "Escuro"
        case .pl: return "Ciemny"
        case .it: return "Scuro"
        default: return "Темна"
        }
    }
    
    private var themeSystemLabel: String {
        switch appState.data.settings.language {
        case .en: return "System"
        case .ru: return "Системная"
        case .es: return "Sistema"
        case .de: return "System"
        case .fr: return "Système"
        case .pt: return "Sistema"
        case .pl: return "Systemowy"
        case .it: return "Sistema"
        default: return "Системна"
        }
    }
    
    private var dataSectionTitle: String {
        switch appState.data.settings.language {
        case .en: return "Data"
        case .ru: return "Данные"
        case .es: return "Datos"
        case .de: return "Daten"
        case .fr: return "Données"
        case .pt: return "Dados"
        case .pl: return "Dane"
        case .it: return "Dati"
        default: return "Дані"
        }
    }
    
    private var exportLabel: String {
        switch appState.data.settings.language {
        case .en: return "Export to JSON"
        case .ru: return "Экспорт в JSON"
        case .es: return "Exportar a JSON"
        case .de: return "Als JSON exportieren"
        case .fr: return "Exporter en JSON"
        case .pt: return "Exportar para JSON"
        case .pl: return "Eksportuj do JSON"
        case .it: return "Esporta in JSON"
        default: return "Експорт у JSON"
        }
    }
    
    private var importLabel: String {
        switch appState.data.settings.language {
        case .en: return "Import from JSON"
        case .ru: return "Импорт из JSON"
        case .es: return "Importar desde JSON"
        case .de: return "Aus JSON importieren"
        case .fr: return "Importer depuis JSON"
        case .pt: return "Importar de JSON"
        case .pl: return "Importuj z JSON"
        case .it: return "Importa da JSON"
        default: return "Імпорт з JSON"
        }
    }
    
    private var csvLabel: String {
        switch appState.data.settings.language {
        case .en: return "Export to CSV"
        case .ru: return "Экспорт в CSV"
        case .es: return "Exportar a CSV"
        case .de: return "Als CSV exportieren"
        case .fr: return "Exporter en CSV"
        case .pt: return "Exportar para CSV"
        case .pl: return "Eksportuj do CSV"
        case .it: return "Esporta in CSV"
        default: return "Експорт у CSV"
        }
    }

    private func exportData() {
        if let url = appState.exportData() {
            shareItem = ShareItem(url: url)
        }
    }

    private func exportCSV() {
        let csv = buildCSV()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("willwin_export.csv")
        do {
            try csv.data(using: .utf8)?.write(to: url, options: [.atomic])
            shareItem = ShareItem(url: url)
        } catch {
            print("CSV export error: \(error)")
        }
    }

    private func buildCSV() -> String {
        func esc(_ s: String) -> String {
            if s.contains(",") || s.contains("\"") || s.contains("\n") {
                return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            }
            return s
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        var rows = ["Week,Workout,Date,Exercise,MuscleGroup,Set,Weight,Reps"]
        for week in appState.data.weeks {
            for workout in week.workouts.sorted(by: { $0.number < $1.number }) {
                let dateStr = df.string(from: workout.date)
                for ex in workout.exercises {
                    let group = ex.muscleGroup?.rawValue ?? ""
                    for (i, set) in ex.sets.enumerated() where set.isFilled {
                        let weightStr = set.weight == floor(set.weight)
                            ? String(Int(set.weight))
                            : String(format: "%.2f", set.weight)
                        rows.append([
                            "\(week.number)",
                            "\(workout.number)",
                            dateStr,
                            esc(ex.name),
                            group,
                            "\(i + 1)",
                            weightStr,
                            "\(set.reps)"
                        ].joined(separator: ","))
                    }
                }
            }
        }
        return rows.joined(separator: "\n")
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            if appState.importData(from: url) {
                importMessage = importSuccessText
            } else {
                importMessage = importFailText
            }
            showingImportAlert = true
        case .failure:
            importMessage = importFailText
            showingImportAlert = true
        }
    }
    
    private var importSuccessText: String {
        switch appState.data.settings.language {
        case .en: return "Data imported successfully"
        case .ru: return "Данные успешно импортированы"
        case .es: return "Datos importados correctamente"
        case .de: return "Daten erfolgreich importiert"
        case .fr: return "Données importées avec succès"
        case .pt: return "Dados importados com sucesso"
        case .pl: return "Dane zaimportowane pomyślnie"
        case .it: return "Dati importati con successo"
        default: return "Дані успішно імпортовано"
        }
    }
    
    private var importFailText: String {
        switch appState.data.settings.language {
        case .en: return "Failed to import data"
        case .ru: return "Не удалось импортировать данные"
        case .es: return "Error al importar datos"
        case .de: return "Daten konnten nicht importiert werden"
        case .fr: return "Échec de l'importation"
        case .pt: return "Falha ao importar dados"
        case .pl: return "Nie udało się zaimportować danych"
        case .it: return "Importazione fallita"
        default: return "Не вдалось імпортувати дані"
        }
    }
    
    private var chartRangeTitle: String {
        switch appState.data.settings.language {
        case .en: return "Chart range"
        case .ru: return "Диапазон графика"
        case .es: return "Rango del gráfico"
        case .de: return "Diagrammbereich"
        case .fr: return "Plage du graphique"
        case .pt: return "Intervalo do gráfico"
        case .pl: return "Zakres wykresu"
        case .it: return "Intervallo grafico"
        default: return "Діапазон графіка"
        }
    }
    
    private func chartRangeLabel(_ range: ProgressChartRange) -> String {
        let lang = appState.data.settings.language
        switch range {
        case .weeks8:
            switch lang {
            case .en: return "8 weeks"
            case .ru: return "8 недель"
            case .es: return "8 semanas"
            case .de: return "8 Wochen"
            case .fr: return "8 semaines"
            case .pt: return "8 semanas"
            case .pl: return "8 tygodni"
            case .it: return "8 settimane"
            default: return "8 тижнів"
            }
        case .weeks16:
            switch lang {
            case .en: return "16 weeks"
            case .ru: return "16 недель"
            case .es: return "16 semanas"
            case .de: return "16 Wochen"
            case .fr: return "16 semaines"
            case .pt: return "16 semanas"
            case .pl: return "16 tygodni"
            case .it: return "16 settimane"
            default: return "16 тижнів"
            }
        case .allTime:
            switch lang {
            case .en: return "All time"
            case .ru: return "Всё время"
            case .es: return "Todo el tiempo"
            case .de: return "Gesamt"
            case .fr: return "Tout le temps"
            case .pt: return "Todo o tempo"
            case .pl: return "Cały czas"
            case .it: return "Sempre"
            default: return "Весь час"
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
