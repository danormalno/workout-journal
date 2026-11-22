import SwiftUI

// MARK: - Формули 1ПМ (чиста математика, без UI)

enum OneRepMaxFormula: String, CaseIterable, Identifiable {
    case epley, brzycki, lander
    var id: String { rawValue }

    /// Оцінка одноповторного максимуму за вагою та повтореннями.
    func estimate(weight: Double, reps: Int) -> Double {
        guard weight > 0, reps > 0 else { return 0 }
        if reps == 1 { return weight }
        let r = Double(reps)
        switch self {
        case .epley:   return weight * (1 + r / 30.0)
        case .brzycki: return r < 37 ? weight * 36.0 / (37.0 - r) : 0   // валідна для < 37 повт.
        case .lander:  return (100.0 * weight) / (101.3 - 2.67123 * r)
        }
    }
}

struct OneRepMax {
    let weight: Double
    let reps: Int

    var perFormula: [(formula: OneRepMaxFormula, value: Double)] {
        OneRepMaxFormula.allCases.map { ($0, $0.estimate(weight: weight, reps: reps)) }
    }

    var average: Double {
        let v = perFormula.map(\.value).filter { $0 > 0 }
        return v.isEmpty ? 0 : v.reduce(0, +) / Double(v.count)
    }

    /// Робочі ваги у % від 1ПМ для планування підходів.
    static let percentTable: [(reps: Int, percent: Double)] = [
        (1, 1.00), (2, 0.97), (3, 0.94), (4, 0.92), (5, 0.89),
        (6, 0.86), (8, 0.81), (10, 0.75), (12, 0.71), (15, 0.65)
    ]
}

// MARK: - Екран

struct OneRepMaxCalculatorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    @State private var weightText: String = ""
    @State private var reps: Int = 5

    private var weight: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var result: OneRepMax { OneRepMax(weight: weight, reps: reps) }
    private var unit: String {
        appState.data.settings.weightUnit == .lb ? s.lb : s.kg
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                Section(L("Дані підходу", "Set data", "Данные подхода", "Datos de la serie",
                          "Satzdaten", "Données de la série", "Dados da série", "Dane serii", "Dati della serie")) {
                    HStack {
                        Text(s.weight)
                        Spacer()
                        TextField("0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text(unit).foregroundStyle(theme.textSecondary)
                    }
                    Stepper("\(s.reps): \(reps)", value: $reps, in: 1...20)
                }

                if weight > 0 {
                    Section(L("Оцінка 1ПМ", "Estimated 1RM", "Оценка 1ПМ", "1RM estimado",
                              "Geschätztes 1RM", "1RM estimé", "1RM estimado", "Szacowane 1RM", "1RM stimato")) {
                        ForEach(result.perFormula, id: \.formula) { item in
                            HStack {
                                Text(formulaName(item.formula))
                                Spacer()
                                Text(item.value > 0 ? "\(fmt(item.value)) \(unit)" : "—")
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                        HStack {
                            Text(L("Середнє", "Average", "Среднее", "Promedio", "Durchschnitt",
                                   "Moyenne", "Média", "Średnia", "Media"))
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(fmt(result.average)) \(unit)").fontWeight(.semibold)
                        }
                    }

                    Section(L("Робочі ваги (% від 1ПМ)", "Working weights (% of 1RM)", "Рабочие веса (% от 1ПМ)",
                              "Pesos de trabajo (% de 1RM)", "Arbeitsgewichte (% von 1RM)", "Charges de travail (% du 1RM)",
                              "Cargas de trabalho (% do 1RM)", "Ciężary robocze (% z 1RM)", "Carichi di lavoro (% del 1RM)")) {
                        ForEach(OneRepMax.percentTable, id: \.reps) { row in
                            HStack {
                                Text("\(row.reps) \(s.reps)")
                                Spacer()
                                Text("\(fmt(result.average * row.percent)) \(unit)")
                                Text("(\(Int(row.percent * 100))%)")
                                    .font(.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(screenTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(s.done) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
                .bold()
            }
        }
    }

    // MARK: - Локалізація

    private var screenTitle: String {
        L("Калькулятор 1ПМ", "1RM Calculator", "Калькулятор 1ПМ", "Calculadora de 1RM",
          "1RM-Rechner", "Calculateur 1RM", "Calculadora de 1RM", "Kalkulator 1RM", "Calcolatore 1RM")
    }

    private func formulaName(_ f: OneRepMaxFormula) -> String {
        switch f {
        case .epley:   return L("Епплі", "Epley", "Эпли", "Epley", "Epley", "Epley", "Epley", "Epley", "Epley")
        case .brzycki: return L("Брзицький", "Brzycki", "Бжицки", "Brzycki", "Brzycki", "Brzycki", "Brzycki", "Brzycki", "Brzycki")
        case .lander:  return L("Лендер", "Lander", "Ландер", "Lander", "Lander", "Lander", "Lander", "Lander", "Lander")
        }
    }

    private func fmt(_ v: Double) -> String { String(format: "%.1f", v) }

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
