import SwiftUI

struct TrainingHeatmapView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    private let weeksToShow = 26
    private let cell: CGFloat = 13
    private let spacing: CGFloat = 3
    @State private var showWeekly = false

    // День (початок доби) -> сумарний тоннаж
    private var tonnageByDay: [Date: Double] {
        var map: [Date: Double] = [:]
        let cal = Calendar.current
        for week in appState.data.weeks {
            for w in week.workouts where w.tonnage > 0 {
                let day = cal.startOfDay(for: w.date)
                map[day, default: 0] += w.tonnage
            }
        }
        return map
    }

    private var maxDay: Double {
        tonnageByDay.values.max() ?? 0
    }

    private var trainedDays: Int {
        tonnageByDay.keys.count
    }

    // Понеділок поточного тижня
    private var thisWeekMonday: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let offset = mondayIndex(today)
        return cal.date(byAdding: .day, value: -offset, to: today)!
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    StreakBar()
                    summary
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: spacing) {
                                ForEach(0..<weeksToShow, id: \.self) { col in
                                    weekColumn(col)
                                        .id(col)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onAppear { proxy.scrollTo(weeksToShow - 1, anchor: .trailing) }
                    }
                    legend
                    weeklyButton
                    AchievementsSection()
                }
                .padding(16)
            }
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showWeekly) {
            WeeklySummarySheet()
                .environmentObject(appState)
                .environment(\.appTheme, theme)
                .environment(\.strings, s)
        }
    }

    private var weeklyButton: some View {
        Button {
            showWeekly = true
        } label: {
            Label(L("Підсумок тижня","Weekly summary","Итоги недели","Resumen semanal","Wochenbilanz",
                    "Bilan de la semaine","Resumo semanal","Podsumowanie tygodnia","Riepilogo settimanale"),
                  systemImage: "square.and.arrow.up")
                .font(.subheadline).fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(theme.accent.opacity(0.12))
                .foregroundStyle(theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(trainedDays)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accent)
            Text(L("днів тренувань за \(weeksToShow) тижнів",
                   "training days in \(weeksToShow) weeks",
                   "дней тренировок за \(weeksToShow) недель",
                   "días de entrenamiento en \(weeksToShow) semanas",
                   "Trainingstage in \(weeksToShow) Wochen",
                   "jours d'entraînement en \(weeksToShow) semaines",
                   "dias de treino em \(weeksToShow) semanas",
                   "dni treningowe w \(weeksToShow) tyg.",
                   "giorni di allenamento in \(weeksToShow) settimane"))
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
    }

    private func weekColumn(_ col: Int) -> some View {
        let cal = Calendar.current
        let columnStart = cal.date(byAdding: .day,
                                   value: -(weeksToShow - 1 - col) * 7,
                                   to: thisWeekMonday)!
        let today = cal.startOfDay(for: Date())
        return VStack(spacing: spacing) {
            ForEach(0..<7, id: \.self) { row in
                let day = cal.date(byAdding: .day, value: row, to: columnStart)!
                if day > today {
                    Color.clear.frame(width: cell, height: cell)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(levelColor(for: tonnageByDay[day] ?? 0))
                        .frame(width: cell, height: cell)
                }
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 6) {
            Text(L("менше", "less", "меньше", "menos", "weniger", "moins", "menos", "mniej", "meno"))
                .font(.caption2).foregroundStyle(theme.textSecondary)
            ForEach(0..<5, id: \.self) { lvl in
                RoundedRectangle(cornerRadius: 3)
                    .fill(colorForLevel(lvl))
                    .frame(width: 12, height: 12)
            }
            Text(L("більше", "more", "больше", "más", "mehr", "plus", "mais", "więcej", "più"))
                .font(.caption2).foregroundStyle(theme.textSecondary)
        }
    }

    // MARK: - Кольори рівнів

    private func levelColor(for tonnage: Double) -> Color {
        guard tonnage > 0, maxDay > 0 else { return colorForLevel(0) }
        let f = tonnage / maxDay
        let lvl = f < 0.25 ? 1 : (f < 0.5 ? 2 : (f < 0.75 ? 3 : 4))
        return colorForLevel(lvl)
    }

    private func colorForLevel(_ lvl: Int) -> Color {
        switch lvl {
        case 1: return theme.accent.opacity(0.30)
        case 2: return theme.accent.opacity(0.50)
        case 3: return theme.accent.opacity(0.75)
        case 4: return theme.accent
        default: return theme.textSecondary.opacity(0.12)
        }
    }

    /// 0 = понеділок ... 6 = неділя
    private func mondayIndex(_ date: Date) -> Int {
        let wd = Calendar.current.component(.weekday, from: date) // 1=нд..7=сб
        return (wd + 5) % 7
    }

    // MARK: - Локалізація

    private var screenTitle: String {
        L("Теплова мапа", "Heatmap", "Тепловая карта", "Mapa de calor", "Heatmap",
          "Carte de chaleur", "Mapa de calor", "Mapa cieplna", "Mappa di calore")
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
