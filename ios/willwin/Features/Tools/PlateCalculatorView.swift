import SwiftUI

// MARK: - Штанга

enum Barbell: String, CaseIterable, Identifiable {
    case olympic, women, training, none
    var id: String { rawValue }

    var weight: Double {
        switch self {
        case .olympic:  return 20
        case .women:    return 15
        case .training: return 10
        case .none:     return 0
        }
    }
}

// MARK: - Диск

struct Plate: Identifiable {
    let id = UUID()
    let weight: Double

    var color: Color {
        switch weight {
        case 25:   return .red
        case 20:   return .blue
        case 15:   return .yellow
        case 10:   return .green
        case 5:    return .white
        case 2.5:  return .black
        case 1.25: return .gray
        case 1:    return Color(red: 0.80, green: 0.80, blue: 0.86)
        case 0.5:  return Color(red: 0.68, green: 0.68, blue: 0.74)
        case 0.25: return Color(red: 0.55, green: 0.55, blue: 0.62)
        default:   return .secondary
        }
    }

    var label: String { Plate.format(weight) }

    /// Формат без зайвих нулів: 25, 2.5, 1.25, 0.5, 0.25
    static func format(_ w: Double) -> String {
        w == floor(w) ? String(Int(w)) : String(format: "%g", w)
    }
}

// MARK: - Логіка

struct PlateCalculator {
    /// Усі диски, доступні для вибору (кг), від важчого до легшого.
    static let allPlateOptions: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25, 1, 0.5, 0.25]

    /// Розкладає вагу на диски для ОДНІЄЇ сторони штанги,
    /// використовуючи лише ввімкнені користувачем диски.
    static func plates(target: Double, bar: Barbell, enabled: Set<Double>) -> (plates: [Plate], remainder: Double) {
        let perSide = (target - bar.weight) / 2.0
        guard perSide > 0 else { return ([], max(0, target - bar.weight)) }

        let usable = allPlateOptions.filter { enabled.contains($0) }  // вже відсортовані за спаданням
        var remaining = perSide
        var result: [Plate] = []
        for p in usable {
            while remaining + 0.0001 >= p {
                result.append(Plate(weight: p))
                remaining -= p
            }
        }
        return (result, remaining * 2)
    }
}

// MARK: - Візуалізація стопки дисків

struct PlateStackView: View {
    let plates: [Plate]

    var body: some View {
        HStack(spacing: 2) {
            Rectangle()
                .fill(.secondary)
                .frame(width: 28, height: 8)
            ForEach(plates) { plate in
                RoundedRectangle(cornerRadius: 3)
                    .fill(plate.color)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(.secondary.opacity(0.5)))
                    .overlay(
                        Text(plate.label)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(plate.weight == 5 ? .black : .white)
                            .rotationEffect(.degrees(-90))
                    )
                    .frame(width: 22, height: plateHeight(plate.weight))
            }
        }
    }

    private func plateHeight(_ w: Double) -> CGFloat {
        switch w {
        case 25:   return 90
        case 20:   return 80
        case 15:   return 70
        case 10:   return 58
        case 5:    return 46
        case 2.5:  return 36
        case 1.25: return 30
        case 1:    return 26
        case 0.5:  return 22
        case 0.25: return 18
        default:   return 20
        }
    }
}

// MARK: - Екран

struct PlateCalculatorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.appTheme) var theme
    @Environment(\.strings) var s

    @State private var targetText: String = ""
    @State private var bar: Barbell = .olympic

    /// Ввімкнені диски — зберігаються назавжди в пам'яті пристрою.
    /// За замовчуванням — усі диски ввімкнені.
    @AppStorage("willwin_enabled_plates")
    private var enabledPlatesRaw: String = PlateCalculator.allPlateOptions
        .map { String($0) }.joined(separator: ",")

    private var enabledPlates: Set<Double> {
        Set(enabledPlatesRaw.split(separator: ",").compactMap { Double($0) })
    }

    private var target: Double {
        Double(targetText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var calc: (plates: [Plate], remainder: Double) {
        PlateCalculator.plates(target: target, bar: bar, enabled: enabledPlates)
    }

    private let chipColumns = [GridItem(.flexible(), spacing: 8),
                               GridItem(.flexible(), spacing: 8)]

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            Form {
                Section(L("Параметри", "Parameters", "Параметры", "Parámetros", "Parameter",
                          "Paramètres", "Parâmetros", "Parametry", "Parametri")) {
                    HStack {
                        Text(L("Цільова вага", "Target weight", "Целевой вес", "Peso objetivo", "Zielgewicht",
                               "Poids cible", "Peso alvo", "Waga docelowa", "Peso target"))
                        Spacer()
                        TextField("0", text: $targetText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text(s.kg).foregroundStyle(theme.textSecondary)
                    }
                    Picker(L("Штанга", "Barbell", "Гриф", "Barra", "Hantelstange",
                             "Barre", "Barra", "Sztanga", "Bilanciere"), selection: $bar) {
                        ForEach(Barbell.allCases) { b in
                            Text(barbellLabel(b)).tag(b)
                        }
                    }
                }

                // Доступні диски (галочки зберігаються назавжди)
                Section {
                    LazyVGrid(columns: chipColumns, spacing: 8) {
                        ForEach(PlateCalculator.allPlateOptions, id: \.self) { p in
                            plateChip(p)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(availablePlatesTitle)
                } footer: {
                    Text(L("Залишаться обраними при наступному запуску.",
                           "Stays selected next time you open the app.",
                           "Останутся выбранными при следующем запуске.",
                           "Permanece seleccionado la próxima vez.",
                           "Bleibt beim nächsten Start ausgewählt.",
                           "Reste sélectionné au prochain lancement.",
                           "Permanece selecionado na próxima vez.",
                           "Pozostanie zaznaczone przy następnym uruchomieniu.",
                           "Rimane selezionato al prossimo avvio."))
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }

                if target > 0 {
                    Section(L("На кожну сторону", "Per side", "На каждую сторону", "Por lado", "Pro Seite",
                              "Par côté", "Por lado", "Na stronę", "Per lato")) {
                        if enabledPlates.isEmpty {
                            Text(L("Оберіть хоча б один диск вище",
                                   "Select at least one plate above",
                                   "Выберите хотя бы один блин выше",
                                   "Selecciona al menos un disco arriba",
                                   "Wähle mindestens eine Scheibe oben",
                                   "Sélectionne au moins un disque ci-dessus",
                                   "Selecione ao menos um disco acima",
                                   "Wybierz co najmniej jeden talerz powyżej",
                                   "Seleziona almeno un disco sopra"))
                                .foregroundStyle(theme.textSecondary)
                        } else if calc.plates.isEmpty {
                            Text(L("Вага менша або дорівнює вазі штанги", "Weight is at or below the bar",
                                   "Вес меньше или равен грифу", "Peso menor o igual a la barra",
                                   "Gewicht ≤ Stange", "Poids ≤ barre", "Peso ≤ barra",
                                   "Waga ≤ sztanga", "Peso ≤ bilanciere"))
                                .foregroundStyle(theme.textSecondary)
                        } else {
                            PlateStackView(plates: calc.plates)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)

                            ForEach(groupedPlates, id: \.weight) { group in
                                HStack {
                                    Circle()
                                        .fill(group.color)
                                        .frame(width: 16, height: 16)
                                        .overlay(Circle().stroke(.secondary.opacity(0.4)))
                                    Text("\(group.label) \(s.kg)")
                                        .foregroundStyle(theme.textPrimary)
                                    Spacer()
                                    Text("× \(group.count)")
                                        .foregroundStyle(theme.textSecondary)
                                }
                            }
                        }

                        if calc.remainder > 0.01 {
                            Text(L("Точно не збирається. Залишок: ", "Cannot match exactly. Remainder: ",
                                   "Точно не собирается. Остаток: ", "No exacto. Resto: ",
                                   "Nicht exakt. Rest: ", "Pas exact. Reste : ",
                                   "Não exato. Resto: ", "Niedokładnie. Reszta: ",
                                   "Non esatto. Resto: ") + "\(String(format: "%.2f", calc.remainder)) \(s.kg)")
                                .font(.caption)
                                .foregroundStyle(.orange)
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

    // MARK: - Чип диска

    private func plateChip(_ p: Double) -> some View {
        let on = enabledPlates.contains(p)
        return Button {
            toggle(p)
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(Plate(weight: p).color)
                    .frame(width: 13, height: 13)
                    .overlay(Circle().stroke(.secondary.opacity(0.4)))
                Text("\(Plate.format(p)) \(s.kg)")
                    .font(.footnote)
                    .foregroundStyle(theme.textPrimary)
                Spacer(minLength: 0)
                Image(systemName: on ? "checkmark.circle.fill" : "circle")
                    .font(.footnote)
                    .foregroundStyle(on ? theme.accent : theme.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(on ? theme.accent.opacity(0.12) : theme.textSecondary.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ p: Double) {
        var set = enabledPlates
        if set.contains(p) { set.remove(p) } else { set.insert(p) }
        // зберігаємо в канонічному порядку
        enabledPlatesRaw = PlateCalculator.allPlateOptions
            .filter { set.contains($0) }
            .map { String($0) }
            .joined(separator: ",")
    }

    private var groupedPlates: [(weight: Double, count: Int, color: Color, label: String)] {
        Dictionary(grouping: calc.plates, by: { $0.weight })
            .map { (weight: $0.key, count: $0.value.count, color: $0.value[0].color, label: $0.value[0].label) }
            .sorted { $0.weight > $1.weight }
    }

    // MARK: - Локалізація

    private var screenTitle: String {
        L("Калькулятор дисків", "Plate Calculator", "Калькулятор дисков", "Calculadora de discos",
          "Scheibenrechner", "Calculateur de disques", "Calculadora de discos", "Kalkulator talerzy", "Calcolatore dischi")
    }

    private var availablePlatesTitle: String {
        L("Доступні диски в залі", "Plates available in your gym", "Доступные блины в зале",
          "Discos disponibles en tu gym", "Verfügbare Scheiben im Studio", "Disques disponibles en salle",
          "Discos disponíveis na academia", "Dostępne talerze na siłowni", "Dischi disponibili in palestra")
    }

    private func barbellLabel(_ b: Barbell) -> String {
        switch b {
        case .olympic:  return L("Олімпійська 20 кг", "Olympic 20 kg", "Олимпийский 20 кг", "Olímpica 20 kg",
                                 "Olympia 20 kg", "Olympique 20 kg", "Olímpica 20 kg", "Olimpijska 20 kg", "Olimpico 20 kg")
        case .women:    return L("Жіноча 15 кг", "Women's 15 kg", "Женский 15 кг", "Femenina 15 kg",
                                 "Damen 15 kg", "Femme 15 kg", "Feminina 15 kg", "Damska 15 kg", "Donna 15 kg")
        case .training: return L("Тренувальна 10 кг", "Training 10 kg", "Тренировочный 10 кг", "Entrenamiento 10 kg",
                                 "Training 10 kg", "Entraînement 10 kg", "Treino 10 kg", "Treningowa 10 kg", "Allenamento 10 kg")
        case .none:     return L("Без штанги", "No bar", "Без грифа", "Sin barra",
                                 "Ohne Stange", "Sans barre", "Sem barra", "Bez sztangi", "Senza barra")
        }
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
