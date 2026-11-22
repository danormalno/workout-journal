import SwiftUI

// MARK: - Рекорд

struct PRRecord: Identifiable {
    let id = UUID()
    let name: String
    let muscleGroup: MuscleGroup?
    let weight: Double
    let reps: Int
    let date: Date

    /// Оцінка 1ПМ за Епплі (для сортування і показу).
    var est1RM: Double {
        reps <= 1 ? weight : weight * (1 + Double(reps) / 30.0)
    }
}

// MARK: - Екран

struct PRTrackerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    private var records: [PRRecord] {
        var best: [String: PRRecord] = [:]
        for (workout, _) in CyclesEngine.chronologicalWorkouts(from: appState.data) {
            for ex in workout.exercises {
                let key = ex.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty, let bs = ex.bestSet else { continue }
                let candidate = PRRecord(name: ex.name, muscleGroup: ex.muscleGroup,
                                         weight: bs.weight, reps: bs.reps, date: workout.date)
                if let existing = best[key] {
                    if bs.weight > existing.weight ||
                       (bs.weight == existing.weight && bs.reps > existing.reps) {
                        best[key] = candidate
                    }
                } else {
                    best[key] = candidate
                }
            }
        }
        return best.values.sorted { $0.est1RM > $1.est1RM }
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            if records.isEmpty {
                emptyState
            } else {
                Form {
                    Section {
                        ForEach(records) { r in
                            recordRow(r)
                        }
                    } footer: {
                        Text(L("1ПМ розраховано за формулою Епплі.",
                               "1RM estimated with the Epley formula.",
                               "1ПМ рассчитан по формуле Эпли.",
                               "1RM estimado con la fórmula de Epley.",
                               "1RM nach Epley-Formel geschätzt.",
                               "1RM estimé avec la formule Epley.",
                               "1RM estimado pela fórmula de Epley.",
                               "1RM oszacowane wzorem Epleya.",
                               "1RM stimato con la formula di Epley."))
                            .font(.caption)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func recordRow(_ r: PRRecord) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(r.name)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(theme.textPrimary)
                HStack(spacing: 6) {
                    if let g = r.muscleGroup {
                        Text(s.muscleGroupName(g))
                    }
                    Text(r.date, style: .date)
                }
                .font(.caption2)
                .foregroundStyle(theme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(fmt(r.weight)) \(s.kg) × \(r.reps)")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundStyle(theme.textPrimary)
                Text("~\(fmt(r.est1RM)) \(s.kg) 1RM")
                    .font(.caption2)
                    .foregroundStyle(theme.accent)
            }
        }
        .padding(.vertical, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 54))
                .foregroundStyle(theme.textSecondary.opacity(0.5))
            Text(L("Поки немає рекордів. Заповни кілька підходів.",
                   "No records yet. Log some sets first.",
                   "Пока нет рекордов. Заполни несколько подходов.",
                   "Aún no hay récords. Registra algunas series.",
                   "Noch keine Rekorde. Trage ein paar Sätze ein.",
                   "Pas encore de records. Enregistre des séries.",
                   "Ainda sem recordes. Registe algumas séries.",
                   "Brak rekordów. Zapisz kilka serii.",
                   "Ancora nessun record. Registra alcune serie."))
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Локалізація

    private var screenTitle: String {
        L("Рекорди (PR)", "Records (PR)", "Рекорды (PR)", "Récords (PR)", "Rekorde (PR)",
          "Records (PR)", "Recordes (PR)", "Rekordy (PR)", "Record (PR)")
    }

    private func fmt(_ v: Double) -> String {
        v == floor(v) ? String(Int(v)) : String(format: "%.1f", v)
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
