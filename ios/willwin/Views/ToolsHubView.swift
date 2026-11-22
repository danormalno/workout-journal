import SwiftUI

/// Хаб «Додаткові інструменти» — збирає всі окремі інструменти.
/// Викликається з основної панелі (WeeksListView), тож власного NavigationStack не має.
struct ToolsHubView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                Section {
                    tool(oneRMTitle, "function") { OneRepMaxCalculatorView() }
                    tool(plateTitle, "circle.grid.2x2") { PlateCalculatorView() }
                    tool(prTitle, "trophy") { PRTrackerView() }
                    tool(tonnageTitle, "chart.bar.fill") { TonnageDashboardView() }
                    tool(heatmapTitle, "square.grid.3x3.fill") { TrainingHeatmapView() }
                    tool(templatesTitle, "square.on.square") { TemplatesView() }
                    tool(photosTitle, "photo.on.rectangle.angled") { ProgressPhotosView() }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(hubTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Універсальний рядок інструмента

    private func tool<Destination: View>(_ title: String,
                                         _ icon: String,
                                         @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            Label(title, systemImage: icon)
                .foregroundStyle(theme.textPrimary)
        }
    }

    // MARK: - Локалізація

    private var hubTitle: String {
        L("Додаткові інструменти", "Extra Tools", "Дополнительные инструменты", "Herramientas extra",
          "Zusatz-Tools", "Outils supplémentaires", "Ferramentas extra", "Dodatkowe narzędzia", "Strumenti extra")
    }
    private var oneRMTitle: String {
        L("Калькулятор 1ПМ", "1RM Calculator", "Калькулятор 1ПМ", "Calculadora de 1RM",
          "1RM-Rechner", "Calculateur 1RM", "Calculadora de 1RM", "Kalkulator 1RM", "Calcolatore 1RM")
    }
    private var plateTitle: String {
        L("Калькулятор дисків", "Plate Calculator", "Калькулятор дисков", "Calculadora de discos",
          "Scheibenrechner", "Calculateur de disques", "Calculadora de discos", "Kalkulator talerzy", "Calcolatore dischi")
    }
    private var prTitle: String {
        L("Рекорди (PR)", "Records (PR)", "Рекорды (PR)", "Récords (PR)", "Rekorde (PR)",
          "Records (PR)", "Recordes (PR)", "Rekordy (PR)", "Record (PR)")
    }
    private var tonnageTitle: String {
        L("Тоннаж", "Tonnage", "Тоннаж", "Tonelaje", "Tonnage", "Tonnage", "Tonelagem", "Tonaż", "Tonnellaggio")
    }
    private var heatmapTitle: String {
        L("Теплова мапа", "Heatmap", "Тепловая карта", "Mapa de calor", "Heatmap",
          "Carte de chaleur", "Mapa de calor", "Mapa cieplna", "Mappa di calore")
    }
    private var templatesTitle: String {
        L("Шаблони", "Templates", "Шаблоны", "Plantillas", "Vorlagen", "Modèles", "Modelos", "Szablony", "Modelli")
    }
    private var photosTitle: String {
        L("Фото прогресу", "Progress Photos", "Фото прогресса", "Fotos de progreso", "Fortschrittsfotos",
          "Photos de progrès", "Fotos de progresso", "Zdjęcia postępów", "Foto dei progressi")
    }

    private func L(_ uk: String, _ en: String, _ ru: String, _ es: String, _ de: String,
                   _ fr: String, _ pt: String, _ pl: String, _ it: String) -> String {
        switch appState.data.settings.language {
        case .en: return en
        case .ru: return ru
        case .es: return es
        case .de: return de
        case .fr: return fr
        case .pt: return pt
        case .pl: return pl
        case .it: return it
        default:  return uk
        }
    }
}
