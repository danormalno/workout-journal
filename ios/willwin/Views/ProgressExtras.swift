import SwiftUI

// =====================================================================
// MARK: - Стрік (серії тижнів із тренуванням)
// =====================================================================

enum StreakEngine {

    private static func mondayStart(of date: Date, _ cal: Calendar) -> Date {
        let sod = cal.startOfDay(for: date)
        let wd = cal.component(.weekday, from: sod) // 1=нд ... 7=сб
        let offset = (wd + 5) % 7                   // 0=пн ... 6=нд
        return cal.date(byAdding: .day, value: -offset, to: sod) ?? sod
    }

    /// Понеділки тих календарних тижнів, у яких було хоча б одне тренування з даними.
    static func trainedWeekStarts(_ data: AppData) -> Set<Date> {
        let cal = Calendar.current
        var set = Set<Date>()
        for week in data.weeks {
            for w in week.workouts where w.hasData {
                set.insert(mondayStart(of: w.date, cal))
            }
        }
        return set
    }

    /// Поточна серія: тижні поспіль до цього (або минулого) тижня включно.
    static func current(_ data: AppData) -> Int {
        let cal = Calendar.current
        let weeks = trainedWeekStarts(data)
        guard !weeks.isEmpty else { return 0 }
        let thisMon = mondayStart(of: Date(), cal)

        var anchor: Date
        if weeks.contains(thisMon) {
            anchor = thisMon
        } else if let lastMon = cal.date(byAdding: .day, value: -7, to: thisMon), weeks.contains(lastMon) {
            anchor = lastMon // цей тиждень ще не закінчився — серія жива
        } else {
            return 0
        }

        var count = 0
        var cur = anchor
        while weeks.contains(cur) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -7, to: cur) else { break }
            cur = prev
        }
        return count
    }

    /// Найдовша серія за весь час.
    static func longest(_ data: AppData) -> Int {
        let cal = Calendar.current
        let weeks = trainedWeekStarts(data).sorted()
        guard weeks.count > 0 else { return 0 }
        var best = 1, run = 1
        for i in 1..<weeks.count {
            if let next = cal.date(byAdding: .day, value: 7, to: weeks[i - 1]),
               cal.isDate(next, inSameDayAs: weeks[i]) {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
        }
        return best
    }

    static func totalWorkouts(_ data: AppData) -> Int {
        data.weeks.flatMap { $0.workouts }.filter { $0.hasData }.count
    }

    static func totalTonnage(_ data: AppData) -> Double {
        data.weeks.flatMap { $0.workouts }.reduce(0) { $0 + $1.tonnage }
    }
}

// =====================================================================
// MARK: - Ачивки
// =====================================================================

struct Achievement: Identifiable {
    let id: String
    let icon: String
    let title: LocStr
    let unlocked: Bool
}

enum AchievementEngine {
    static func all(_ data: AppData) -> [Achievement] {
        let workouts = StreakEngine.totalWorkouts(data)
        let tonnage = StreakEngine.totalTonnage(data)
        let longest = StreakEngine.longest(data)

        func a(_ id: String, _ icon: String, _ unlocked: Bool, _ t: LocStr) -> Achievement {
            Achievement(id: id, icon: icon, title: t, unlocked: unlocked)
        }

        return [
            a("first", "figure.strengthtraining.traditional", workouts >= 1,
              LocStr("Перший крок","First step","Первый шаг","Primer paso","Erster Schritt","Premier pas","Primeiro passo","Pierwszy krok","Primo passo")),
            a("w10", "flame.fill", workouts >= 10,
              LocStr("10 тренувань","10 workouts","10 тренировок","10 entrenamientos","10 Workouts","10 séances","10 treinos","10 treningów","10 allenamenti")),
            a("w50", "flame.fill", workouts >= 50,
              LocStr("50 тренувань","50 workouts","50 тренировок","50 entrenamientos","50 Workouts","50 séances","50 treinos","50 treningów","50 allenamenti")),
            a("w100", "crown.fill", workouts >= 100,
              LocStr("100 тренувань","100 workouts","100 тренировок","100 entrenamientos","100 Workouts","100 séances","100 treinos","100 treningów","100 allenamenti")),
            a("streak4", "calendar", longest >= 4,
              LocStr("4 тижні поспіль","4-week streak","4 недели подряд","4 semanas seguidas","4 Wochen am Stück","4 semaines d'affilée","4 semanas seguidas","4 tygodnie z rzędu","4 settimane di fila")),
            a("streak12", "calendar.badge.checkmark", longest >= 12,
              LocStr("12 тижнів поспіль","12-week streak","12 недель подряд","12 semanas seguidas","12 Wochen am Stück","12 semaines d'affilée","12 semanas seguidas","12 tygodni z rzędu","12 settimane di fila")),
            a("t50", "scalemass.fill", tonnage >= 50_000,
              LocStr("50 тонн піднято","50 tons lifted","50 тонн поднято","50 toneladas levantadas","50 Tonnen gehoben","50 tonnes soulevées","50 toneladas levantadas","50 ton podniesione","50 tonnellate sollevate")),
            a("t250", "scalemass.fill", tonnage >= 250_000,
              LocStr("250 тонн піднято","250 tons lifted","250 тонн поднято","250 toneladas levantadas","250 Tonnen gehoben","250 tonnes soulevées","250 toneladas levantadas","250 ton podniesione","250 tonnellate sollevate")),
            a("t1000", "trophy.fill", tonnage >= 1_000_000,
              LocStr("1000 тонн піднято","1000 tons lifted","1000 тонн поднято","1000 toneladas levantadas","1000 Tonnen gehoben","1000 tonnes soulevées","1000 toneladas levantadas","1000 ton podniesione","1000 tonnellate sollevate")),
        ]
    }
}

// =====================================================================
// MARK: - Тижневий підсумок (по об'єкту Тиждень)
// =====================================================================

struct WeekPR: Identifiable { let id = UUID(); let name: String; let weight: Double }

struct WeekStats {
    let title: String
    let tonnage: Double
    let workouts: Int
    let prs: [WeekPR]
    let topExercise: String?
    let topExerciseTonnage: Double
}

enum WeekSummaryEngine {

    /// Найсвіжіший Тиждень із даними.
    static func latest(_ data: AppData, lang: AppLanguage?) -> WeekStats? {
        guard let idx = data.weeks.lastIndex(where: { week in
            week.workouts.contains(where: { $0.hasData })
        }) else { return nil }

        let week = data.weeks[idx]
        let title = week.customName.isEmpty
            ? "\(weekWord(lang)) \(week.number)"
            : week.customName

        let tonnage = week.workouts.reduce(0) { $0 + $1.tonnage }
        let workouts = week.workouts.filter { $0.hasData }.count

        // Найкраща вага за вправою в цьому тижні
        var weekBest: [String: Double] = [:]
        var weekTon: [String: Double] = [:]
        for w in week.workouts {
            for ex in w.exercises {
                let key = ex.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard !key.isEmpty else { continue }
                let best = ex.sets.filter { $0.isFilled }.map { $0.weight }.max() ?? 0
                if best > (weekBest[key] ?? 0) { weekBest[key] = best }
                weekTon[key, default: 0] += ex.tonnage
            }
        }

        // Найкраща вага за вправою в попередніх тижнях
        var priorBest: [String: Double] = [:]
        for i in 0..<idx {
            for w in data.weeks[i].workouts {
                for ex in w.exercises {
                    let key = ex.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    guard !key.isEmpty else { continue }
                    let best = ex.sets.filter { $0.isFilled }.map { $0.weight }.max() ?? 0
                    if best > (priorBest[key] ?? 0) { priorBest[key] = best }
                }
            }
        }

        // Рекорди: цьоготижнева вага перевищує все попереднє
        var prs: [WeekPR] = []
        for (key, best) in weekBest where best > 0 && best > (priorBest[key] ?? 0) {
            let display = originalName(for: key, in: week) ?? key
            prs.append(WeekPR(name: display, weight: best))
        }
        prs.sort { $0.weight > $1.weight }

        let top = weekTon.max(by: { $0.value < $1.value })
        let topName = top.flatMap { originalName(for: $0.key, in: week) }

        return WeekStats(title: title, tonnage: tonnage, workouts: workouts,
                         prs: prs, topExercise: topName, topExerciseTonnage: top?.value ?? 0)
    }

    private static func originalName(for key: String, in week: Week) -> String? {
        for w in week.workouts {
            for ex in w.exercises where ex.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == key {
                return ex.name
            }
        }
        return nil
    }

    private static func weekWord(_ lang: AppLanguage?) -> String {
        LocStr("Тиждень","Week","Неделя","Semana","Woche","Semaine","Semana","Tydzień","Settimana").s(lang)
    }
}

// =====================================================================
// MARK: - UI: стрічка стріку
// =====================================================================

struct StreakBar: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        let cur = StreakEngine.current(appState.data)
        let longest = StreakEngine.longest(appState.data)
        HStack(spacing: 14) {
            stat(value: "\(cur)", caption: LocStr("тижнів поспіль","week streak","недель подряд","semanas seguidas","Wochen-Serie","semaines d'affilée","semanas seguidas","tygodni z rzędu","settimane di fila").s(lang), icon: "flame.fill", tint: cur > 0 ? .orange : theme.textSecondary)
            Divider().frame(height: 34)
            stat(value: "\(longest)", caption: LocStr("рекорд серії","longest streak","рекорд серии","racha máxima","längste Serie","plus longue série","maior sequência","najdłuższa seria","serie più lunga").s(lang), icon: "trophy.fill", tint: theme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func stat(value: String, caption: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(.title3).fontWeight(.bold).foregroundStyle(theme.textPrimary)
                Text(caption).font(.caption2).foregroundStyle(theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// =====================================================================
// MARK: - UI: ачивки
// =====================================================================

struct AchievementsSection: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    private var lang: AppLanguage? { appState.data.settings.language }

    private let columns = [GridItem(.adaptive(minimum: 90), spacing: 10)]

    var body: some View {
        let items = AchievementEngine.all(appState.data)
        VStack(alignment: .leading, spacing: 10) {
            Text(LocStr("Досягнення","Achievements","Достижения","Logros","Erfolge","Réalisations","Conquistas","Osiągnięcia","Obiettivi").s(lang))
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(theme.textSecondary)
                .textCase(.uppercase)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    VStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.title2)
                            .foregroundStyle(item.unlocked ? theme.accent : theme.textSecondary.opacity(0.35))
                        Text(item.title.s(lang))
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(item.unlocked ? theme.textPrimary : theme.textSecondary.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, minHeight: 78)
                    .padding(8)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .opacity(item.unlocked ? 1 : 0.7)
                }
            }
        }
    }
}

// =====================================================================
// MARK: - UI: тижнева картка + поділитися
// =====================================================================

struct WeeklySummaryCard: View {
    let stats: WeekStats
    let theme: AppTheme
    let lang: AppLanguage?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "dumbbell.fill").foregroundStyle(theme.accent)
                Text(stats.title)
                    .font(.headline).foregroundStyle(theme.textPrimary)
                Spacer()
                Text(LocStr("Підсумок тижня","Weekly summary","Итоги недели","Resumen semanal","Wochenbilanz","Bilan de la semaine","Resumo semanal","Podsumowanie tygodnia","Riepilogo settimanale").s(lang))
                    .font(.caption2).foregroundStyle(theme.textSecondary)
            }

            HStack(spacing: 12) {
                bigStat("\(Int(stats.tonnage))", LocStr("кг тоннаж","kg tonnage","кг тоннаж","kg tonelaje","kg Tonnage","kg tonnage","kg tonelagem","kg tonaż","kg tonnellaggio").s(lang))
                bigStat("\(stats.workouts)", LocStr("тренувань","workouts","тренировок","entrenos","Workouts","séances","treinos","treningów","allenamenti").s(lang))
                bigStat("\(stats.prs.count)", LocStr("нових PR","new PRs","новых PR","nuevos PR","neue PRs","nouveaux PR","novos PR","nowych PR","nuovi PR").s(lang))
            }

            if !stats.prs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocStr("Нові рекорди","New records","Новые рекорды","Nuevos récords","Neue Rekorde","Nouveaux records","Novos recordes","Nowe rekordy","Nuovi record").s(lang))
                        .font(.caption).fontWeight(.semibold).foregroundStyle(theme.textSecondary)
                    ForEach(stats.prs.prefix(4)) { pr in
                        HStack {
                            Image(systemName: "arrow.up.circle.fill").font(.caption2).foregroundStyle(.green)
                            Text(pr.name).font(.caption).foregroundStyle(theme.textPrimary).lineLimit(1)
                            Spacer()
                            Text("\(formatW(pr.weight)) kg").font(.caption).fontWeight(.semibold).foregroundStyle(theme.accent)
                        }
                    }
                }
            }

            if let top = stats.topExercise, stats.topExerciseTonnage > 0 {
                HStack {
                    Image(systemName: "star.fill").font(.caption2).foregroundStyle(theme.accent)
                    Text(LocStr("Топ-вправа","Top lift","Топ-упражнение","Top ejercicio","Top-Übung","Top exercice","Top exercício","Top ćwiczenie","Top esercizio").s(lang) + ": ")
                        .font(.caption).foregroundStyle(theme.textSecondary)
                    Text(top).font(.caption).fontWeight(.medium).foregroundStyle(theme.textPrimary).lineLimit(1)
                    Spacer()
                }
            }

            Text("Workout Journal")
                .font(.caption2).foregroundStyle(theme.textSecondary.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(18)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(theme.accent.opacity(0.25), lineWidth: 1))
    }

    private func bigStat(_ value: String, _ caption: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(theme.accent)
            Text(caption).font(.caption2).foregroundStyle(theme.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatW(_ v: Double) -> String { v == floor(v) ? "\(Int(v))" : String(format: "%.1f", v) }
}

private struct ShareImageItem: Identifiable { let id = UUID(); let image: UIImage }

struct WeeklySummarySheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s
    @Environment(\.dismiss) var dismiss

    @State private var shareItem: ShareImageItem? = nil
    private var lang: AppLanguage? { appState.data.settings.language }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    if let stats = WeekSummaryEngine.latest(appState.data, lang: lang) {
                        WeeklySummaryCard(stats: stats, theme: theme, lang: lang)
                            .padding(.horizontal, 4)
                        Button {
                            shareCard(stats)
                        } label: {
                            Label(LocStr("Поділитися","Share","Поделиться","Compartir","Teilen","Partager","Compartilhar","Udostępnij","Condividi").s(lang),
                                  systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(theme.accent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        Text(LocStr("Ще нема завершених тренувань цього тижня.","No completed workouts yet.","Пока нет завершённых тренировок.","Aún no hay entrenamientos completados.","Noch keine abgeschlossenen Workouts.","Aucune séance terminée pour l'instant.","Ainda não há treinos concluídos.","Brak ukończonych treningów.","Ancora nessun allenamento completato.").s(lang))
                            .font(.subheadline)
                            .foregroundStyle(theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle(LocStr("Підсумок тижня","Weekly Summary","Итоги недели","Resumen semanal","Wochenbilanz","Bilan de la semaine","Resumo semanal","Podsumowanie tygodnia","Riepilogo settimanale").s(lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button(s.done) { dismiss() } }
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.image])
        }
    }

    @MainActor
    private func shareCard(_ stats: WeekStats) {
        let card = WeeklySummaryCard(stats: stats, theme: theme, lang: lang)
            .padding(20)
            .frame(width: 380)
            .background(theme.background)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        if let ui = renderer.uiImage {
            shareItem = ShareImageItem(image: ui)
        }
    }
}
