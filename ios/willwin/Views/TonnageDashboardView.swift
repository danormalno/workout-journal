import SwiftUI

struct TonnageDashboardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    // MARK: - Дані

    private var totalTonnage: Double {
        appState.data.weeks.reduce(0) { $0 + $1.tonnage }
    }

    private var workoutsWithData: Int {
        CyclesEngine.chronologicalWorkouts(from: appState.data).count
    }

    private var totalSets: Int {
        var n = 0
        for week in appState.data.weeks {
            for w in week.workouts {
                for ex in w.exercises {
                    n += ex.sets.filter { $0.isFilled }.count
                }
            }
        }
        return n
    }

    private var byMuscle: [(group: MuscleGroup, tonnage: Double)] {
        var map: [MuscleGroup: Double] = [:]
        for week in appState.data.weeks {
            for w in week.workouts {
                for ex in w.exercises where ex.tonnage > 0 {
                    map[ex.muscleGroup ?? .other, default: 0] += ex.tonnage
                }
            }
        }
        return map.map { (group: $0.key, tonnage: $0.value) }
            .sorted { $0.tonnage > $1.tonnage }
    }

    private var topExercises: [(name: String, tonnage: Double)] {
        var map: [String: (name: String, tonnage: Double)] = [:]
        for week in appState.data.weeks {
            for w in week.workouts {
                for ex in w.exercises where ex.tonnage > 0 {
                    let key = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !key.isEmpty else { continue }
                    map[key, default: (ex.name, 0)].tonnage += ex.tonnage
                    map[key]?.name = ex.name
                }
            }
        }
        return map.values.map { (name: $0.name, tonnage: $0.tonnage) }
            .sorted { $0.tonnage > $1.tonnage }
            .prefix(5).map { $0 }
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            if totalTonnage <= 0 {
                emptyState
            } else {
                Form {
                    // Підсумок
                    Section {
                        summaryRow(title: totalLabel, value: "\(Int(totalTonnage).formatted()) \(s.kg)", accent: true)
                        summaryRow(title: workoutsLabel, value: "\(workoutsWithData)", accent: false)
                        summaryRow(title: setsLabel, value: "\(totalSets)", accent: false)
                    }

                    // По групах м'язів
                    if !byMuscle.isEmpty {
                        Section(byMuscleLabel) {
                            ForEach(byMuscle, id: \.group) { item in
                                barRow(title: s.muscleGroupName(item.group),
                                       tonnage: item.tonnage,
                                       maxTonnage: byMuscle.first?.tonnage ?? 1)
                            }
                        }
                    }

                    // Топ вправ
                    if !topExercises.isEmpty {
                        Section(topLabel) {
                            ForEach(Array(topExercises.enumerated()), id: \.offset) { idx, item in
                                HStack {
                                    Text("\(idx + 1).")
                                        .font(.subheadline).fontWeight(.bold)
                                        .foregroundStyle(theme.accent)
                                        .frame(width: 24, alignment: .leading)
                                    Text(item.name)
                                        .foregroundStyle(theme.textPrimary)
                                    Spacer()
                                    Text("\(Int(item.tonnage).formatted()) \(s.kg)")
                                        .font(.subheadline)
                                        .foregroundStyle(theme.textSecondary)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Рядки

    private func summaryRow(title: String, value: String, accent: Bool) -> some View {
        HStack {
            Text(title).foregroundStyle(theme.textSecondary)
            Spacer()
            Text(value)
                .font(accent ? .title3 : .body)
                .fontWeight(accent ? .bold : .regular)
                .foregroundStyle(accent ? theme.accent : theme.textPrimary)
        }
    }

    private func barRow(title: String, tonnage: Double, maxTonnage: Double) -> some View {
        let fraction = maxTonnage > 0 ? CGFloat(tonnage / maxTonnage) : 0
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).foregroundStyle(theme.textPrimary)
                Spacer()
                Text("\(Int(tonnage).formatted()) \(s.kg)")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(theme.textSecondary.opacity(0.15))
                    Capsule().fill(theme.accent)
                        .frame(width: max(4, geo.size.width * fraction))
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "scalemass")
                .font(.system(size: 54))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text(L("Поки немає даних про тоннаж.",
                   "No tonnage data yet.",
                   "Пока нет данных о тоннаже.",
                   "Aún no hay datos de tonelaje.",
                   "Noch keine Tonnage-Daten.",
                   "Pas encore de données de tonnage.",
                   "Ainda sem dados de tonelagem.",
                   "Brak danych o tonażu.",
                   "Ancora nessun dato sul tonnellaggio."))
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Локалізація

    private var screenTitle: String {
        L("Тоннаж", "Tonnage", "Тоннаж", "Tonelaje", "Tonnage", "Tonnage", "Tonelagem", "Tonaż", "Tonnellaggio")
    }
    private var totalLabel: String {
        L("Загальний тоннаж", "Total tonnage", "Общий тоннаж", "Tonelaje total", "Gesamt-Tonnage",
          "Tonnage total", "Tonelagem total", "Całkowity tonaż", "Tonnellaggio totale")
    }
    private var workoutsLabel: String {
        L("Тренувань", "Workouts", "Тренировок", "Entrenamientos", "Workouts",
          "Séances", "Treinos", "Treningi", "Allenamenti")
    }
    private var setsLabel: String {
        L("Підходів", "Sets", "Подходов", "Series", "Sätze", "Séries", "Séries", "Serie", "Serie")
    }
    private var byMuscleLabel: String {
        L("За групами м'язів", "By muscle group", "По группам мышц", "Por grupo muscular", "Nach Muskelgruppe",
          "Par groupe musculaire", "Por grupo muscular", "Wg grupy mięśniowej", "Per gruppo muscolare")
    }
    private var topLabel: String {
        L("Топ вправ", "Top exercises", "Топ упражнений", "Top ejercicios", "Top-Übungen",
          "Top exercices", "Top exercícios", "Top ćwiczeń", "Top esercizi")
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
